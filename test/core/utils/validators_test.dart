import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/utils/validators.dart';

void main() {
  final localFaker = Faker();

  group('AppValidators.required', () {
    test('should return null when value is non-empty', () {
      final result = AppValidators.required('hello');
      expect(result, isNull);
    });

    test('should return error message when value is null or empty', () {
      expect(AppValidators.required(null), isNotNull);
      expect(AppValidators.required(''), isNotNull);
      expect(AppValidators.required('   '), isNotNull);
    });
  });

  group('AppValidators.email', () {
    test('should return null when email is valid', () {
      final validEmail = localFaker.internet.email();
      final result = AppValidators.email(validEmail);
      expect(result, isNull);
    });

    test('should return error message when email is invalid', () {
      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email('test@domain'), isNotNull);
      expect(AppValidators.email('@domain.com'), isNotNull);
    });

    test('should return null when email is null or empty', () {
      expect(AppValidators.email(null), isNull);
      expect(AppValidators.email(''), isNull);
    });
  });

  group('AppValidators.password', () {
    test('should return null when password meets all strength criteria', () {
      // Min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char
      final result = AppValidators.password('P@ssword123');
      expect(result, isNull);
    });

    test('should return error message when password lacks uppercase', () {
      final result = AppValidators.password('p@ssword123');
      expect(result, isNotNull);
    });

    test('should return error message when password is too short', () {
      final result = AppValidators.password('P@ss1');
      expect(result, isNotNull);
    });

    test('should return null when password is null or empty', () {
      expect(AppValidators.password(null), isNull);
      expect(AppValidators.password(''), isNull);
    });
  });

  group('AppValidators.confirmPassword', () {
    test('should return null when passwords match', () {
      final result = AppValidators.confirmPassword('P@ss1234', 'P@ss1234');
      expect(result, isNull);
    });

    test('should return error message when passwords do not match', () {
      final result = AppValidators.confirmPassword('P@ss1234', 'Diff1234');
      expect(result, isNotNull);
    });
  });

  group('AppValidators.saudiPhone', () {
    test('should return null when Saudi phone number is valid', () {
      expect(AppValidators.saudiPhone('0512345678'), isNull);
      expect(AppValidators.saudiPhone('+966512345678'), isNull);
      expect(AppValidators.saudiPhone('00966512345678'), isNull);
      expect(AppValidators.saudiPhone('512345678'), isNull);
    });

    test('should return error message when Saudi phone number is invalid', () {
      expect(AppValidators.saudiPhone('0412345678'), isNotNull); // Non-5 starting number
      expect(AppValidators.saudiPhone('0512345'), isNotNull); // Too short
      expect(AppValidators.saudiPhone('051234567890'), isNotNull); // Too long
      expect(AppValidators.saudiPhone('05abc45678'), isNotNull); // Non-numeric
    });

    test('should return null when phone is null or empty', () {
      expect(AppValidators.saudiPhone(null), isNull);
      expect(AppValidators.saudiPhone(''), isNull);
    });
  });

  group('AppValidators.minLength', () {
    test('should return null when value meets minimum length', () {
      final result = AppValidators.minLength('hello', 3);
      expect(result, isNull);
    });

    test('should return error when value is under minimum length', () {
      final result = AppValidators.minLength('he', 3);
      expect(result, isNotNull);
    });
  });

  group('AppValidators.maxLength', () {
    test('should return null when value does not exceed maximum length', () {
      final result = AppValidators.maxLength('hello', 8);
      expect(result, isNull);
    });

    test('should return error when value exceeds maximum length', () {
      final result = AppValidators.maxLength('helloworld', 8);
      expect(result, isNotNull);
    });
  });

  group('AppValidators.numeric', () {
    test('should return null when value is numeric', () {
      expect(AppValidators.numeric('123'), isNull);
      expect(AppValidators.numeric('-123.45'), isNull);
    });

    test('should return error when value is non-numeric', () {
      expect(AppValidators.numeric('123a'), isNotNull);
      expect(AppValidators.numeric('abc'), isNotNull);
    });
  });

  group('AppValidators.arabicOnly', () {
    test('should return null when value contains Arabic text only', () {
      final result = AppValidators.arabicOnly('مرحبا بك');
      expect(result, isNull);
    });

    test('should return error when value contains Latin text', () {
      final result = AppValidators.arabicOnly('مرحبا بك welcome');
      expect(result, isNotNull);
    });
  });

  group('AppValidators.latitude', () {
    test('should return null when latitude is between -90.0 and 90.0', () {
      expect(AppValidators.latitude('0.0'), isNull);
      expect(AppValidators.latitude('-45.123'), isNull);
      expect(AppValidators.latitude('90.0'), isNull);
      expect(AppValidators.latitude('-90.0'), isNull);
    });

    test('should return error when latitude is outside boundaries', () {
      expect(AppValidators.latitude('-90.1'), isNotNull);
      expect(AppValidators.latitude('91.0'), isNotNull);
      expect(AppValidators.latitude('abc'), isNotNull);
    });
  });

  group('AppValidators.longitude', () {
    test('should return null when longitude is between -180.0 and 180.0', () {
      expect(AppValidators.longitude('0.0'), isNull);
      expect(AppValidators.longitude('-120.45'), isNull);
      expect(AppValidators.longitude('180.0'), isNull);
      expect(AppValidators.longitude('-180.0'), isNull);
    });

    test('should return error when longitude is outside boundaries', () {
      expect(AppValidators.longitude('-180.1'), isNotNull);
      expect(AppValidators.longitude('180.5'), isNotNull);
      expect(AppValidators.longitude('xyz'), isNotNull);
    });
  });

  group('AppValidators.saudiPlateNumber', () {
    test('should return null when Saudi plate number matches format', () {
      expect(AppValidators.saudiPlateNumber('1234 abc'), isNull);
      expect(AppValidators.saudiPlateNumber('999 xyz'), isNull);
      expect(AppValidators.saudiPlateNumber('123أبج'), isNull);
    });

    test('should return error when Saudi plate format is incorrect', () {
      expect(AppValidators.saudiPlateNumber('12345 abc'), isNotNull); // Too many digits
      expect(AppValidators.saudiPlateNumber('123 ab'), isNotNull); // Too few letters
      expect(AppValidators.saudiPlateNumber('abc 1234'), isNotNull); // Wrong order
    });
  });

  group('AppValidators.compose', () {
    test('should return null when all validators pass', () {
      final result = AppValidators.compose('test@domain.com', [
        (val) => AppValidators.required(val),
        (val) => AppValidators.email(val),
      ]);
      expect(result, isNull);
    });

    test('should return the first validation error that triggers', () {
      final result = AppValidators.compose('', [
        (val) => AppValidators.required(val, fieldName: 'Email'),
        (val) => AppValidators.email(val),
      ]);
      expect(result, contains('Email is required.'));
    });
  });
}
