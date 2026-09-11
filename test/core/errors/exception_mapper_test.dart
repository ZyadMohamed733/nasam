import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exception_mapper.dart';
import 'package:nasam/core/errors/exceptions.dart';

void main() {
  final requestOptions = RequestOptions(path: '/templates/1');

  DioException dioError(DioExceptionType type, {Object? error}) =>
      DioException(requestOptions: requestOptions, type: type, error: error);

  DioException httpError(int statusCode, {Object? data}) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
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
    test('401 maps to AuthException', () {
      final result = ExceptionMapper.fromDioException(httpError(401));
      expect(result, isA<AuthException>());
      expect(result.code, '401');
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

    test('422 maps to ValidationException', () {
      final result = ExceptionMapper.fromDioException(httpError(422));
      expect(result, isA<ValidationException>());
      expect(result.code, '422');
    });

    test('400 falls through to UnknownException', () {
      expect(
        ExceptionMapper.fromDioException(httpError(400)),
        isA<UnknownException>(),
      );
    });

    for (final statusCode in [500, 502, 503, 599]) {
      test('$statusCode maps to ServerException', () {
        final result = ExceptionMapper.fromDioException(httpError(statusCode));
        expect(result, isA<ServerException>());
        expect(result.code, statusCode.toString());
      });
    }
  });

  group('parseFieldErrors', () {
    test('reads the documented 422 shape', () {
      final result = ExceptionMapper.fromDioException(
        httpError(
          422,
          data: {
            'errors': {
              'plate_number': ['Already registered.', 'Must be uppercase.'],
              'driver_id': ['Unknown driver.'],
            },
          },
        ),
      );

      expect((result as ValidationException).fieldErrors, {
        'plate_number': ['Already registered.', 'Must be uppercase.'],
        'driver_id': ['Unknown driver.'],
      });
    });

    test('accepts a bare string per field', () {
      expect(
        ExceptionMapper.parseFieldErrors({
          'errors': {'plate_number': 'Already registered.'},
        }),
        {
          'plate_number': ['Already registered.'],
        },
      );
    });

    // A malformed error body must not mask the error it describes.
    test('returns empty for shapes it does not recognise', () {
      expect(ExceptionMapper.parseFieldErrors(null), isEmpty);
      expect(ExceptionMapper.parseFieldErrors('nope'), isEmpty);
      expect(ExceptionMapper.parseFieldErrors({'errors': 'nope'}), isEmpty);
      expect(
        ExceptionMapper.parseFieldErrors(<String, Object>{
          'other': <String, Object>{},
        }),
        isEmpty,
      );
      expect(
        ExceptionMapper.parseFieldErrors({
          'errors': {
            'plate_number': [1, 2],
          },
        }),
        isEmpty,
      );
    });

    test('a 422 with no body yields an empty map, not a throw', () {
      final result = ExceptionMapper.fromDioException(httpError(422));
      expect((result as ValidationException).fieldErrors, isEmpty);
    });
  });
}
