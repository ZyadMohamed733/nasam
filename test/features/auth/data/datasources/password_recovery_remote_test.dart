import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_settings_controller.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/network/dio_client.dart';
import 'package:nasam/core/network/interceptors/auth_interceptor.dart';
import 'package:nasam/core/network/interceptors/language_interceptor.dart';
import 'package:nasam/features/auth/data/datasources/remote/auth_remote_datasource.dart';

import '../../../../helpers/mock_helper.dart';
import '../../../../helpers/recording_adapter.dart';

class _MockRefresher extends Mock implements TokenRefresher {}

/// The recovery endpoints as the app actually calls them: the real Dio base
/// options (base URL, headers), the real auth and language interceptors, and
/// a recording transport in place of the network.
void main() {
  const config = AppConfig(
    flavor: Flavor.dev,
    appName: 'Nasam',
    baseUrl: 'https://nasam-v2-api-dev.nasam.net/api/v1',
    wsUrl: 'wss://ws-dev.nasam.app',
    tenant: 'saudi-tracking',
  );
  const email = 'user@example.com';

  late RecordingAdapter api;
  late _MockRefresher refresher;
  late AuthRemoteDataSource remote;

  setUp(() {
    // A leftover session token that must not ride along on these calls.
    final storage = MockSecureStorageService();
    when(storage.getAccessToken).thenAnswer((_) async => 'stale-access');
    when(() => storage.sessionVersion).thenReturn(0);
    refresher = _MockRefresher();

    final prefs = MockStorageService();
    when(prefs.getLocale).thenReturn('ar');
    when(prefs.getThemeMode).thenReturn(null);

    api = RecordingAdapter((_) => (200, {'message': 'ok'}));
    final dio = Dio(DioClient.baseOptions(config))
      ..httpClientAdapter = api
      ..interceptors.addAll([
        AuthInterceptor(storage, refresher, MockDio()),
        LanguageInterceptor(AppSettingsController(prefs)),
      ]);
    remote = AuthRemoteDataSourceImpl(dio);
  });

  RequestOptions sent() => api.requests.single;

  void expectUnauthenticatedHeaders(RequestOptions request) {
    expect(request.headers['Content-Type'], 'application/json');
    expect(request.headers['Accept'], 'application/json');
    expect(request.headers['x-lang'], 'ar');
    expect(request.headers['x-tenant'], 'saudi-tracking');
    expect(
      request.headers.containsKey('Authorization'),
      isFalse,
      reason: 'recovery is for signed-out users; no session token is sent',
    );
  }

  group('request code', () {
    test('POSTs the email to /api/v1/auth/forget-password', () async {
      await remote.forgetPassword(email);

      expect(sent().method, 'POST');
      expect(
        sent().uri.toString(),
        'https://nasam-v2-api-dev.nasam.net/api/v1/auth/forget-password',
      );
      expect(sent().data, {'email': email});
      expectUnauthenticatedHeaders(sent());
    });
  });

  group('verify code', () {
    test(
      'POSTs email and the code as a string, keeping a leading zero',
      () async {
        api.respond = (_) => (
          200,
          {'message': 'OTP verified successfully.', 'resetToken': 'tok-1'},
        );

        final token = await remote.verifyResetOtp(email: email, code: '012345');

        expect(token, 'tok-1');
        expect(sent().method, 'POST');
        expect(
          sent().uri.toString(),
          'https://nasam-v2-api-dev.nasam.net/api/v1/auth/verify-reset-otp',
        );
        expect(sent().data, {'email': email, 'code': '012345'});
        expect((sent().data as Map)['code'], isA<String>());
        expectUnauthenticatedHeaders(sent());
      },
    );

    for (final (label, body) in [
      ('missing', <String, dynamic>{'message': 'OTP verified successfully.'}),
      ('empty', <String, dynamic>{'message': 'ok', 'resetToken': ''}),
      ('not a string', <String, dynamic>{'resetToken': 12345}),
    ]) {
      test('a 200 with a $label resetToken is an unexpected response', () {
        api.respond = (_) => (200, body);
        expect(
          remote.verifyResetOtp(email: email, code: '123456'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.code,
              'code',
              'missing_reset_token',
            ),
          ),
        );
      });
    }

    test('a token under `data` is read too', () async {
      api.respond = (_) => (
        200,
        {
          'data': {'resetToken': 'tok-2'},
        },
      );
      expect(
        await remote.verifyResetOtp(email: email, code: '123456'),
        'tok-2',
      );
    });
  });

  group('reset password', () {
    test('PATCHes the token and new password, and nothing else', () async {
      await remote.resetPassword(resetToken: 'tok-1', newPassword: 'N3w!pass');

      expect(sent().method, 'PATCH');
      expect(
        sent().uri.toString(),
        'https://nasam-v2-api-dev.nasam.net/api/v1/auth/reset-password',
      );
      expect(sent().data, {'resetToken': 'tok-1', 'newPassword': 'N3w!pass'});
      expectUnauthenticatedHeaders(sent());
    });
  });

  // A 401 on a recovery call belongs to that call. It must not start a token
  // refresh, which could end or expire a session the user is not using.
  group('a 401 is handed back, without a refresh', () {
    final calls = <String, Future<void> Function(AuthRemoteDataSource)>{
      'forget-password': (r) => r.forgetPassword(email),
      'verify-reset-otp': (r) => r.verifyResetOtp(email: email, code: '123456'),
      'reset-password': (r) =>
          r.resetPassword(resetToken: 'tok', newPassword: 'N3w!pass'),
    };
    calls.forEach((name, call) {
      test(name, () async {
        api.respond = (_) => (401, {'message': 'nope'});

        await expectLater(call(remote), throwsA(isA<AuthException>()));

        verifyNever(refresher.refresh);
        expect(api.requests, hasLength(1), reason: 'no retry');
      });
    });
  });

  group('errors keep the backend message', () {
    Map<String, dynamic> error(int status, String message) => {
      'statusCode': status,
      'path': '/api/v1/auth/forget-password',
      'message': message,
    };

    test('400: invalid email', () {
      api.respond = (_) => (400, error(400, 'email must be an email'));
      expect(
        remote.forgetPassword('nope'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'email must be an email',
          ),
        ),
      );
    });

    test('404: account not found', () {
      api.respond = (_) => (404, error(404, 'No account with that email.'));
      expect(
        remote.forgetPassword(email),
        throwsA(
          isA<ServerException>()
              .having(
                (e) => e.message,
                'message',
                'No account with that email.',
              )
              .having((e) => e.code, 'code', '404'),
        ),
      );
    });

    test('429: rate limited', () {
      api.respond = (_) => (429, error(429, 'Try again in 5 minutes.'));
      expect(
        remote.forgetPassword(email),
        throwsA(
          isA<RateLimitException>().having(
            (e) => e.message,
            'message',
            'Try again in 5 minutes.',
          ),
        ),
      );
    });

    test('400 on verify: invalid or expired code', () {
      api.respond = (_) => (400, error(400, 'Invalid or expired OTP.'));
      expect(
        remote.verifyResetOtp(email: email, code: '000000'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Invalid or expired OTP.',
          ),
        ),
      );
    });

    test('no connection', () {
      api.respond = (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
      expect(remote.forgetPassword(email), throwsA(isA<NetworkException>()));
    });
  });
}
