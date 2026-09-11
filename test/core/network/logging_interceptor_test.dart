import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/network/interceptors/logging_interceptor.dart';

Object? redact(Object? value) => LoggingInterceptor.redact(value);

void main() {
  group('redaction', () {
    test('masks an Authorization header regardless of case', () {
      for (final key in ['Authorization', 'authorization', 'AUTHORIZATION']) {
        final result = redact(<String, Object?>{key: 'Bearer abc.def'});
        expect((result! as Map)[key], '[REDACTED]', reason: 'key: $key');
      }
    });

    // The login request body went to the log verbatim before this.
    test('masks a password in a request body', () {
      final result = redact(<String, Object?>{
        'email': 'operator@nasam.app',
        'password': 'hunter2',
      });
      expect((result! as Map)['password'], '[REDACTED]');
      expect((result as Map)['email'], 'operator@nasam.app');
    });

    test('masks token fields in any naming style', () {
      final result =
          redact(<String, Object?>{
                'access_token': 'a',
                'refreshToken': 'b',
                'apiKey': 'c',
                'otp': 'd',
                'pin': 'e',
              })
              as Map;
      expect(result.values.every((v) => v == '[REDACTED]'), isTrue);
    });

    test('masks nested and listed values', () {
      final result =
          redact(<String, Object?>{
                'user': <String, Object?>{
                  'name': 'Yousef',
                  'password': 'hunter2',
                },
                'sessions': [
                  <String, Object?>{'token': 'abc'},
                ],
              })
              as Map;

      expect((result['user'] as Map)['password'], '[REDACTED]');
      expect((result['user'] as Map)['name'], 'Yousef');
      expect(
        ((result['sessions'] as List).first as Map)['token'],
        '[REDACTED]',
      );
    });

    test('leaves non-sensitive values intact', () {
      expect(redact('plain'), 'plain');
      expect(redact(42), 42);
      expect(redact(null), isNull);
    });
  });

  group('truncation', () {
    test('caps a long body and says how much was dropped', () {
      final long = 'x' * 5000;
      final result = LoggingInterceptor.truncate(long);
      expect(result.length, lessThan(long.length));
      expect(result, contains('truncated'));
    });

    test('leaves a short body untouched', () {
      expect(LoggingInterceptor.truncate('short'), 'short');
    });
  });
}
