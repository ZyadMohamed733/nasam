import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/network/interceptors/auth_interceptor.dart';

import '../../helpers/mock_helper.dart';

class _FakeErrorHandler extends ErrorInterceptorHandler {
  final resolved = <Response<dynamic>>[];
  final forwarded = <DioException>[];

  @override
  void resolve(Response<dynamic> response) => resolved.add(response);

  @override
  void next(DioException err) => forwarded.add(err);
}

class _MockRefresher extends Mock implements TokenRefresher {}

void main() {
  late MockSecureStorageService storage;
  late MockDio bare;
  late AuthInterceptor interceptor;

  /// Refresh calls, which the test can hold open with [gate].
  late List<String> refreshCalls;
  Completer<Response<Map<String, dynamic>>>? gate;

  // A fresh RequestOptions per call: onError sets extra['isRetry'] on it, so a
  // shared instance would leak that flag into later tests.
  RequestOptions origin() =>
      RequestOptions(path: '/vehicles', baseUrl: 'https://api.test');

  DioException unauthorized() {
    final options = origin();
    return DioException(
      requestOptions: options,
      response: Response<dynamic>(requestOptions: options, statusCode: 401),
    );
  }

  Response<Map<String, dynamic>> refreshed() => Response(
    requestOptions: origin(),
    statusCode: 200,
    data: const {
      'data': {'accessToken': 'new-access'},
    },
  );

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    storage = MockSecureStorageService();
    when(() => storage.hasAccessToken).thenReturn(true);
    when(() => storage.sessionVersion).thenReturn(0);
    when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-access');
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
    when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => storage.clearAuth()).thenAnswer((_) async {});

    refreshCalls = [];
    gate = null;
    bare = MockDio();
    when(
      () => bare.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((invocation) {
      refreshCalls.add(invocation.positionalArguments.first as String);
      return gate?.future ?? Future.value(refreshed());
    });
    when(() => bare.fetch<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: origin(),
        statusCode: 200,
        data: 'ok',
      ),
    );

    // The real refresher: the single-flight lock lives there now.
    final refresher = TokenRefresher(
      storage,
      AuthSessionNotifier(storage),
      bare,
      MockErrorReporter(),
    );
    interceptor = AuthInterceptor(storage, refresher, bare);
  });

  group('concurrency', () {
    // Five parallel requests against an expired token must not send five
    // refreshes: with rotation the first would invalidate the other four.
    test('five concurrent 401s trigger exactly one refresh', () async {
      gate = Completer();
      final handlers = List.generate(5, (_) => _FakeErrorHandler());

      final inFlight = [
        for (final handler in handlers)
          interceptor.onError(unauthorized(), handler),
      ];

      await Future<void>.delayed(Duration.zero);
      expect(refreshCalls, hasLength(1));

      gate!.complete(refreshed());
      await Future.wait(inFlight);

      expect(refreshCalls.single, TokenRefresher.refreshPath);
      verify(() => storage.saveAccessToken('new-access')).called(1);
      // Every caller got its request retried with the new token.
      expect(handlers.every((h) => h.resolved.length == 1), isTrue);
      final retried = verify(() => bare.fetch<dynamic>(captureAny())).captured;
      expect(retried, hasLength(5));
      for (final options in retried.cast<RequestOptions>()) {
        expect(options.headers['Authorization'], 'Bearer new-access');
      }
    });

    test(
      'a later 401 starts a fresh refresh once the first has settled',
      () async {
        await interceptor.onError(unauthorized(), _FakeErrorHandler());
        await interceptor.onError(unauthorized(), _FakeErrorHandler());

        expect(refreshCalls, hasLength(2));
      },
    );
  });

  test('a failed refresh hands the original 401 on', () async {
    final rejected = origin();
    when(
      () => bare.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenThrow(
      DioException(
        requestOptions: rejected,
        response: Response<dynamic>(requestOptions: rejected, statusCode: 401),
      ),
    );
    final original = unauthorized();
    final handler = _FakeErrorHandler();

    await interceptor.onError(original, handler);

    expect(handler.forwarded.single, same(original));
    verifyNever(() => bare.fetch<dynamic>(any()));
  });

  // The refresh can succeed and still be for a session that has since
  // ended; replaying the request would act for a signed-out user.
  // The refresh can succeed and still be for a session that has since
  // ended; replaying the request would act for a signed-out user. A stub
  // refresher that returns a token anyway isolates the interceptor's own
  // check from the refresher's.
  test('no retry if the session ended while the refresh was out', () async {
    var version = 0;
    when(() => storage.sessionVersion).thenAnswer((_) => version);
    final refresher = _MockRefresher();
    when(refresher.refresh).thenAnswer((_) async {
      version++; // the user signed out meanwhile
      return 'new-access';
    });
    final guarded = AuthInterceptor(storage, refresher, bare);
    final original = unauthorized();
    final handler = _FakeErrorHandler();

    await guarded.onError(original, handler);

    expect(handler.forwarded.single, same(original));
    expect(handler.resolved, isEmpty);
    verifyNever(() => bare.fetch<dynamic>(any()));
  });

  group('pass-through', () {
    test('a non-401 is forwarded untouched', () async {
      final handler = _FakeErrorHandler();

      await interceptor.onError(
        DioException(
          requestOptions: origin(),
          response: Response<dynamic>(
            requestOptions: origin(),
            statusCode: 500,
          ),
        ),
        handler,
      );

      expect(refreshCalls, isEmpty);
      expect(handler.forwarded, hasLength(1));
    });

    // Without this the retried request 401s again and refreshes forever.
    test('an already-retried request is not refreshed again', () async {
      final retried = RequestOptions(
        path: '/vehicles',
        baseUrl: 'https://api.test',
        extra: {'isRetry': true},
      );

      final handler = _FakeErrorHandler();
      await interceptor.onError(
        DioException(
          requestOptions: retried,
          response: Response<dynamic>(requestOptions: retried, statusCode: 401),
        ),
        handler,
      );

      expect(refreshCalls, isEmpty);
      expect(handler.forwarded, hasLength(1));
    });
  });

  group('onRequest', () {
    test('attaches the bearer token when one is stored', () async {
      final options = RequestOptions(path: '/vehicles');
      await interceptor.onRequest(options, RequestInterceptorHandler());
      expect(options.headers['Authorization'], 'Bearer old-access');
    });

    test('attaches nothing when no token is stored', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/vehicles');
      await interceptor.onRequest(options, RequestInterceptorHandler());
      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
