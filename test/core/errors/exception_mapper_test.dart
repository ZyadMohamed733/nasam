import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exception_mapper.dart';
import 'package:nasam/core/errors/exceptions.dart';

void main() {
  final requestOptions = RequestOptions(path: '/auth/login');

  DioException dioError(DioExceptionType type, {Object? error}) =>
      DioException(requestOptions: requestOptions, type: type, error: error);

  DioException httpError(
    int statusCode, {
    Object? data,
    Map<String, List<String>>? headers,
  }) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
      headers: headers == null ? null : Headers.fromMap(headers),
    ),
  );

  group('DioExceptionType coverage', () {
    test('connectionTimeout maps to NetworkException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.connectionTimeout),
        ),
        isA<NetworkException>(),
      );
    });

    test('connectionError maps to NetworkException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.connectionError),
        ),
        isA<NetworkException>(),
      );
    });

    test('a SocketException maps to NetworkException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.unknown, error: const SocketException('')),
        ),
        isA<NetworkException>(),
      );
    });

    test('receiveTimeout maps to TimeoutException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.receiveTimeout),
        ),
        isA<TimeoutException>(),
      );
    });

    test('sendTimeout maps to TimeoutException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.sendTimeout),
        ),
        isA<TimeoutException>(),
      );
    });

    test('cancel maps to UnknownException', () {
      expect(
        ExceptionMapper.fromDioException(dioError(DioExceptionType.cancel)),
        isA<UnknownException>(),
      );
    });

    test('badCertificate maps to UnknownException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.badCertificate),
        ),
        isA<UnknownException>(),
      );
    });

    test('unknown with no response maps to UnknownException', () {
      expect(
        ExceptionMapper.fromDioException(dioError(DioExceptionType.unknown)),
        isA<UnknownException>(),
      );
    });

    test('badResponse with no status code maps to UnknownException', () {
      expect(
        ExceptionMapper.fromDioException(
          dioError(DioExceptionType.badResponse),
        ),
        isA<UnknownException>(),
      );
    });
  });

  group('status code coverage', () {
    test('401 uses the server message verbatim when present', () {
      final result = ExceptionMapper.fromDioException(
        httpError(401, data: {'message': 'Invalid username or password.'}),
      );
      expect(result, isA<AuthException>());
      expect(result.code, '401');
      expect(result.message, 'Invalid username or password.');
    });

    test('401 with no body message falls back to a generic message', () {
      final result = ExceptionMapper.fromDioException(httpError(401));
      expect(result, isA<AuthException>());
      expect(result.code, '401');
      expect(result.message, isNotEmpty);
    });

    test('403 maps to PermissionException', () {
      final result = ExceptionMapper.fromDioException(httpError(403));
      expect(result, isA<PermissionException>());
      expect(result.code, '403');
    });

    test('404 maps to ServerException', () {
      final result = ExceptionMapper.fromDioException(httpError(404));
      expect(result, isA<ServerException>());
      expect(result.code, '404');
    });

    for (final statusCode in [500, 502, 503, 599]) {
      test('$statusCode maps to ServerException', () {
        final result = ExceptionMapper.fromDioException(httpError(statusCode));
        expect(result, isA<ServerException>());
        expect(result.code, statusCode.toString());
      });
    }
  });

  group('400 validation errors', () {
    test('a single string message maps to ValidationException', () {
      final result = ExceptionMapper.fromDioException(
        httpError(400, data: {'message': 'email must be a valid email address'}),
      );
      expect(result, isA<ValidationException>());
      expect(result.code, '400');
      expect(result.message, 'email must be a valid email address');
      expect((result as ValidationException).fieldErrors, {
        'email': ['email must be a valid email address'],
      });
    });

    test('an array of class-validator sentences groups by leading field name', () {
      final result = ExceptionMapper.fromDioException(
        httpError(
          400,
          data: {
            'message': [
              'username should not be empty',
              'password should not be empty',
            ],
          },
        ),
      );

      expect((result as ValidationException).message, 'username should not be empty');
      expect(result.fieldErrors, {
        'username': ['username should not be empty'],
        'password': ['password should not be empty'],
      });
    });

    test('a 400 with no recognisable body yields a generic validation failure, not a throw', () {
      final result = ExceptionMapper.fromDioException(httpError(400));
      expect(result, isA<ValidationException>());
      expect((result as ValidationException).fieldErrors, isEmpty);
    });
  });

  group('429 rate limiting', () {
    test('reads retryAfterSeconds from the Retry-After header', () {
      final result = ExceptionMapper.fromDioException(
        httpError(
          429,
          data: {'message': 'Too many attempts.'},
          headers: {
            'retry-after': ['120'],
          },
        ),
      );

      expect(result, isA<RateLimitException>());
      expect(result.code, '429');
      expect((result as RateLimitException).retryAfterSeconds, 120);
      expect(result.message, 'Too many attempts.');
    });

    test('falls back to parsing minutes out of the message when the header is missing', () {
      final result = ExceptionMapper.fromDioException(
        httpError(429, data: {'message': 'Try again in 3 minutes.'}),
      );

      expect((result as RateLimitException).retryAfterSeconds, 180);
    });

    test('is null when neither the header nor the message says how long', () {
      final result = ExceptionMapper.fromDioException(httpError(429));
      expect((result as RateLimitException).retryAfterSeconds, isNull);
    });
  });
}
