import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

void main() {
  late AuthInterceptor interceptor;
  late MockSecureStorageService storage;

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

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    storage = MockSecureStorageService();
    interceptor = AuthInterceptor(storage);

    when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-access');
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
    when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => storage.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => storage.clearAll()).thenAnswer((_) async {});
  });

  /// Counts refresh calls and lets the test control when they complete.
  ({
    MockDio dio,
    List<String> calls,
    Completer<Response<Map<String, dynamic>>> gate,
  })
  refreshClient({bool gated = false}) {
    final dio = MockDio();
    final calls = <String>[];
    final gate = Completer<Response<Map<String, dynamic>>>();

    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((invocation) {
      calls.add(invocation.positionalArguments.first as String);
      if (gated) return gate.future;
      return Future.value(
        Response<Map<String, dynamic>>(
          requestOptions: origin(),
          statusCode: 200,
          data: const {
            'accessToken': 'new-access',
            'refreshToken': 'refresh-2',
          },
        ),
      );
    });

    when(() => dio.fetch<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: origin(),
        statusCode: 200,
        data: 'ok',
      ),
    );

    interceptor.refreshClientFactory = (_) => dio;
    return (dio: dio, calls: calls, gate: gate);
  }

  group('concurrency', () {
    // The bug: as a factory-scoped interceptor with no lock, five parallel
    // requests against an expired token sent five refreshes, and with token
    // rotation the first response invalidated the other four.
    test('five concurrent 401s trigger exactly one refresh', () async {
      final client = refreshClient(gated: true);
      final handlers = List.generate(5, (_) => _FakeErrorHandler());

      final inFlight = [
        for (final handler in handlers)
          interceptor.onError(unauthorized(), handler),
      ];

      // All five are now waiting on the same refresh.
      await Future<void>.delayed(Duration.zero);
      expect(client.calls, hasLength(1));

      client.gate.complete(
        Response<Map<String, dynamic>>(
          requestOptions: origin(),
          statusCode: 200,
          data: const {
            'accessToken': 'new-access',
            'refreshToken': 'refresh-2',
          },
        ),
      );
      await Future.wait(inFlight);

      expect(client.calls, hasLength(1));
      expect(client.calls.single, contains('/auth/refresh'));
      verify(() => storage.saveAccessToken('new-access')).called(1);
      // Every caller got its request retried and resolved.
      expect(handlers.every((h) => h.resolved.length == 1), isTrue);
    });

    test(
      'a later 401 starts a fresh refresh once the first has settled',
      () async {
        final client = refreshClient();

        await interceptor.onError(unauthorized(), _FakeErrorHandler());
        await interceptor.onError(unauthorized(), _FakeErrorHandler());

        expect(client.calls, hasLength(2));
      },
    );
  });

  group('credential clearing', () {
    test('a 401 from the refresh endpoint clears credentials', () async {
      final dio = MockDio();
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: origin(),
          response: Response<dynamic>(
            requestOptions: origin(),
            statusCode: 401,
          ),
        ),
      );
      interceptor.refreshClientFactory = (_) => dio;

      final handler = _FakeErrorHandler();
      await interceptor.onError(unauthorized(), handler);

      verify(() => storage.clearAll()).called(1);
      expect(handler.forwarded, hasLength(1));
    });

    test('a 403 from the refresh endpoint clears credentials', () async {
      final dio = MockDio();
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: origin(),
          response: Response<dynamic>(
            requestOptions: origin(),
            statusCode: 403,
          ),
        ),
      );
      interceptor.refreshClientFactory = (_) => dio;

      await interceptor.onError(unauthorized(), _FakeErrorHandler());

      verify(() => storage.clearAll()).called(1);
    });

    // A two-second network blip is not a revoked token. The previous
    // `catch (_)` wiped credentials on any refresh failure.
    test('a timeout during refresh does NOT clear credentials', () async {
      final dio = MockDio();
      when(
        () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: origin(),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      interceptor.refreshClientFactory = (_) => dio;

      final handler = _FakeErrorHandler();
      await interceptor.onError(unauthorized(), handler);

      verifyNever(() => storage.clearAll());
      expect(handler.forwarded, hasLength(1));
    });

    test(
      'a connection error during refresh does NOT clear credentials',
      () async {
        final dio = MockDio();
        when(
          () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: origin(),
            type: DioExceptionType.connectionError,
          ),
        );
        interceptor.refreshClientFactory = (_) => dio;

        await interceptor.onError(unauthorized(), _FakeErrorHandler());

        verifyNever(() => storage.clearAll());
      },
    );

    test('no stored refresh token clears credentials', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => null);

      await interceptor.onError(unauthorized(), _FakeErrorHandler());

      verify(() => storage.clearAll()).called(1);
    });
  });

  group('pass-through', () {
    test('a non-401 is forwarded untouched', () async {
      final client = refreshClient();
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

      expect(client.calls, isEmpty);
      expect(handler.forwarded, hasLength(1));
    });

    // Without this the retried request 401s again and refreshes forever.
    test('an already-retried request is not refreshed again', () async {
      final client = refreshClient();
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

      expect(client.calls, isEmpty);
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
