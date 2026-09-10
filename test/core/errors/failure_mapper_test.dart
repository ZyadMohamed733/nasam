import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/errors/failure_mapper.dart';
import 'package:nasam/core/errors/failures.dart';

void main() {
  group('FailureMapper', () {
    const cases = <AppException, Type>{
      NetworkException(message: 'm'): NetworkFailure,
      ServerException(message: 'm'): ServerFailure,
      CacheException(message: 'm'): CacheFailure,
      ValidationException(message: 'm'): ValidationFailure,
      AuthException(message: 'm'): AuthFailure,
      PermissionException(message: 'm'): PermissionFailure,
      TimeoutException(message: 'm'): TimeoutFailure,
      UnknownException(message: 'm'): UnknownFailure,
    };

    cases.forEach((exception, expectedType) {
      test('${exception.runtimeType} maps to $expectedType', () {
        expect(
          FailureMapper.fromException(exception).runtimeType,
          expectedType,
        );
      });
    });

    test('carries message and code across the boundary', () {
      final failure = FailureMapper.fromException(
        const ServerException(message: 'Server error.', code: '503'),
      );
      expect(failure.message, 'Server error.');
      expect(failure.code, '503');
    });

    test('carries fieldErrors across the boundary', () {
      final failure = FailureMapper.fromException(
        const ValidationException(
          message: 'Validation failed.',
          fieldErrors: {
            'plate_number': ['Already registered.'],
          },
          code: '422',
        ),
      );
      expect((failure as ValidationFailure).fieldErrors, {
        'plate_number': ['Already registered.'],
      });
    });
  });

  group('ValidationFailure equality', () {
    test('equal when fieldErrors match', () {
      expect(
        const ValidationFailure(
          message: 'm',
          fieldErrors: {
            'a': ['x'],
          },
        ),
        const ValidationFailure(
          message: 'm',
          fieldErrors: {
            'a': ['x'],
          },
        ),
      );
    });

    test('not equal when fieldErrors differ', () {
      expect(
        const ValidationFailure(
          message: 'm',
          fieldErrors: {
            'a': ['x'],
          },
        ),
        isNot(
          const ValidationFailure(
            message: 'm',
            fieldErrors: {
              'a': ['y'],
            },
          ),
        ),
      );
    });

    test('hashCode agrees with equality', () {
      const a = ValidationFailure(
        message: 'm',
        fieldErrors: {
          'a': ['x'],
        },
      );
      const b = ValidationFailure(
        message: 'm',
        fieldErrors: {
          'a': ['x'],
        },
      );
      expect(a.hashCode, b.hashCode);
    });
  });
}
