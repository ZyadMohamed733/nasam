import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'package:nasam/core/errors/error_reporter.dart';
import 'package:nasam/core/network/dio_client.dart';
import 'package:nasam/core/network/interceptors/logging_interceptor.dart';

import '../../helpers/mock_helper.dart';
import '../../helpers/recording_adapter.dart';

void main() {
  const config = AppConfig(
    flavor: Flavor.staging,
    appName: 'Nasam',
    baseUrl: 'https://api.test/v1',
    wsUrl: 'wss://ws.test',
    tenant: 'tenant-from-config',
  );

  setUpAll(() => registerFallbackValue(StackTrace.empty));

  late MockSecureStorageService storage;
  late AuthSessionNotifier session;
  late RecordingAdapter adapter;
  late TokenRefresher refresher;
  late MockErrorReporter errors;

  setUp(() {
    storage = MockSecureStorageService();
    when(() => storage.hasAccessToken).thenReturn(true);
    when(() => storage.sessionVersion).thenReturn(0);
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
    when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => storage.saveUser(any())).thenAnswer((_) async {});
    when(() => storage.clearAuth()).thenAnswer((_) async {});
    session = AuthSessionNotifier(storage);

    adapter = RecordingAdapter(
      (_) => (
        200,
        {
          'data': {
            'accessToken': 'new-access',
            'user': {'id': 'user-1'},
          },
        },
      ),
    );
    // The client the app actually builds, with only the transport swapped.
    final client = DioClient.bare(
      config: config,
      loggingInterceptor: LoggingInterceptor(),
    )..httpClientAdapter = adapter;
    errors = MockErrorReporter();
    refresher = TokenRefresher(storage, session, client, errors);
  });

  group('the refresh request', () {
    test('carries X-Client and the tenant from AppConfig', () async {
      await refresher.refresh();

      final request = adapter.requests.single;
      expect(
        request.uri.toString(),
        'https://api.test/v1/auth/refresh-access-token',
      );
      expect(request.headers['X-Client'], 'mobile');
      expect(request.headers['x-tenant'], 'tenant-from-config');
      expect(request.data, {'refreshToken': 'refresh-1'});
    });

    test('uses the main client\'s timeouts, send timeout included', () async {
      await refresher.refresh();

      final request = adapter.requests.single;
      expect(
        request.connectTimeout,
        const Duration(milliseconds: AppConstants.connectTimeoutMs),
      );
      expect(
        request.receiveTimeout,
        const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      );
      expect(
        request.sendTimeout,
        const Duration(milliseconds: AppConstants.sendTimeoutMs),
      );
    });

    test('a success stores the new token and the refreshed user', () async {
      expect(await refresher.refresh(), 'new-access');

      verify(() => storage.saveAccessToken('new-access')).called(1);
      verify(() => storage.saveUser('{"id":"user-1"}')).called(1);
      expect(session.value, AuthSessionStatus.signedIn);
    });
  });

  group('ends the session', () {
    for (final status in [400, 401, 403, 422]) {
      test('on a $status from the refresh endpoint', () async {
        adapter.respond = (_) => (status, {'message': 'no'});

        expect(await refresher.refresh(), isNull);

        verify(() => storage.clearAuth()).called(1);
        expect(session.value, AuthSessionStatus.expired);
      });
    }

    test('when there is no refresh token to send', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => null);

      expect(await refresher.refresh(), isNull);

      expect(adapter.requests, isEmpty);
      verify(() => storage.clearAuth()).called(1);
      expect(session.value, AuthSessionStatus.expired);
    });

    test('and says so even if clearing the keychain fails', () async {
      adapter.respond = (_) => (401, null);
      when(() => storage.clearAuth()).thenThrow(StateError('keychain'));

      expect(await refresher.refresh(), isNull);
      expect(session.value, AuthSessionStatus.expired);
    });
  });

  // A network blip is not a revoked token; signing the user out for one is
  // the bug this guards.
  group('keeps the session', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('on ${type.name}', () async {
        adapter.respond = (options) =>
            throw DioException(requestOptions: options, type: type);

        expect(await refresher.refresh(), isNull);

        verifyNever(() => storage.clearAuth());
        expect(session.value, AuthSessionStatus.signedIn);
      });
    }

    test('on a 500', () async {
      adapter.respond = (_) => (500, null);

      expect(await refresher.refresh(), isNull);

      verifyNever(() => storage.clearAuth());
      expect(session.value, AuthSessionStatus.signedIn);
    });
  });

  // A 200 without a token breaks the API contract; it says nothing about the
  // refresh token, so the user keeps their session and someone gets told.
  test('a 200 without an access token is reported, not a sign-out', () async {
    adapter.respond = (_) => (200, {'data': <String, dynamic>{}});

    expect(await refresher.refresh(), isNull);

    final report = verify(
      () => errors.report(
        captureAny(),
        any(),
        source: ErrorSource.contract,
        context: any(named: 'context'),
      ),
    ).captured.single;
    expect(report, isA<ApiContractViolation>());
    verifyNever(() => storage.clearAuth());
    verifyNever(() => storage.saveAccessToken(any()));
    expect(session.value, AuthSessionStatus.signedIn);
  });

  test('a 200 with no data at all is reported the same way', () async {
    adapter.respond = (_) => (200, {'message': 'ok'});

    expect(await refresher.refresh(), isNull);

    verify(
      () => errors.report(
        any(),
        any(),
        source: ErrorSource.contract,
        context: any(named: 'context'),
      ),
    ).called(1);
    expect(session.value, AuthSessionStatus.signedIn);
  });

  group('a sign-out while the refresh is out', () {
    late Completer<(int, Object?)> reply;
    var version = 0;

    setUp(() {
      version = 0;
      when(() => storage.sessionVersion).thenAnswer((_) => version);
      reply = Completer();
      adapter.respond = (_) => reply.future;
    });

    test('a late 200 is dropped, not saved', () async {
      final pending = refresher.refresh();
      await pumpEventQueue();
      expect(adapter.requests, hasLength(1));

      version++; // clearAuth ran
      reply.complete((
        200,
        {
          'data': {
            'accessToken': 'resurrected',
            'user': {'id': 'user-1'},
          },
        },
      ));

      expect(await pending, isNull);
      verifyNever(() => storage.saveAccessToken(any()));
      verifyNever(() => storage.saveUser(any()));
    });

    test('a late rejection does not report an expiry', () async {
      session.signOut();
      final pending = refresher.refresh();
      await pumpEventQueue();

      version++;
      reply.complete((401, null));

      expect(await pending, isNull);
      verifyNever(() => storage.clearAuth());
      expect(session.value, AuthSessionStatus.signedOut);
    });
  });

  test(
    'a rejection while already signed out is not reported as expiry',
    () async {
      session.signOut();
      adapter.respond = (_) => (401, null);

      await refresher.refresh();

      expect(session.value, AuthSessionStatus.signedOut);
    },
  );
}
