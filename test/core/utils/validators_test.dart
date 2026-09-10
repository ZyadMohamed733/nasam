import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/utils/validation_error.dart';
import 'package:nasam/core/utils/validators.dart';

void main() {
  final localFaker = Faker();

  group('AppValidators.required', () {
    test('should return null when value is non-empty', () {
      expect(AppValidators.required('hello'), isNull);
    });

    test('should return RequiredFieldError when value is null or empty', () {
      expect(AppValidators.required(null), isA<RequiredFieldError>());
      expect(AppValidators.required(''), isA<RequiredFieldError>());
      expect(AppValidators.required('   '), isA<RequiredFieldError>());
    });

    test('carries the field name when given one', () {
      final error = AppValidators.required(null, fieldName: 'Email');
      expect((error! as RequiredFieldError).fieldName, 'Email');
    });
  });

  group('AppValidators.email', () {
    test('should return null when email is valid', () {
      expect(AppValidators.email(localFaker.internet.email()), isNull);
    });

    test('should return InvalidEmailError when email is invalid', () {
      expect(AppValidators.email('invalid-email'), isA<InvalidEmailError>());
      expect(AppValidators.email('test@domain'), isA<InvalidEmailError>());
      expect(AppValidators.email('@domain.com'), isA<InvalidEmailError>());
    });
  });

  group('AppValidators.password', () {
    test('should return null when password meets all strength criteria', () {
      expect(AppValidators.password('P@ssword123'), isNull);
    });

    test('should return PasswordTooWeakError when password lacks uppercase', () {
      expect(AppValidators.password('p@ssword123'), isA<PasswordTooWeakError>());
    });

    test('should return PasswordTooWeakError when password is too short', () {
      expect(AppValidators.password('P@ss1'), isA<PasswordTooWeakError>());
    });
  });

  group('AppValidators.confirmPassword', () {
    test('should return null when passwords match', () {
      expect(AppValidators.confirmPassword('P@ss1234', 'P@ss1234'), isNull);
    });

    test('should return PasswordMismatchError when they differ', () {
      expect(
        AppValidators.confirmPassword('P@ss1234', 'Diff1234'),
        isA<PasswordMismatchError>(),
      );
    });
  });

  group('AppValidators.saudiPhone', () {
    test('should return null when Saudi phone number is valid', () {
      expect(AppValidators.saudiPhone('0512345678'), isNull);
      expect(AppValidators.saudiPhone('+966512345678'), isNull);
      expect(AppValidators.saudiPhone('00966512345678'), isNull);
      expect(AppValidators.saudiPhone('512345678'), isNull);
    });

    test('should return InvalidPhoneError when the number is invalid', () {
      expect(AppValidators.saudiPhone('0412345678'), isA<InvalidPhoneError>());
      expect(AppValidators.saudiPhone('0512345'), isA<InvalidPhoneError>());
      expect(AppValidators.saudiPhone('051234567890'), isA<InvalidPhoneError>());
      expect(AppValidators.saudiPhone('05abc45678'), isA<InvalidPhoneError>());
    });
  });

  // The previous behaviour reported every blank value as valid, so a submitted
  // empty form passed validation entirely.
  group('blank handling', () {
    test('blank fails by default across every validator', () {
      expect(AppValidators.email(''), isA<RequiredFieldError>());
      expect(AppValidators.email(null), isA<RequiredFieldError>());
      expect(AppValidators.password(''), isA<RequiredFieldError>());
      expect(AppValidators.saudiPhone(''), isA<RequiredFieldError>());
      expect(AppValidators.numeric('   '), isA<RequiredFieldError>());
      expect(AppValidators.minLength('', 3), isA<RequiredFieldError>());
      expect(AppValidators.maxLength('', 3), isA<RequiredFieldError>());
      expect(AppValidators.arabicOnly(''), isA<RequiredFieldError>());
      expect(AppValidators.latitude(''), isA<RequiredFieldError>());
      expect(AppValidators.longitude(''), isA<RequiredFieldError>());
      expect(AppValidators.saudiPlateNumber(''), isA<RequiredFieldError>());
    });

    test('blank passes when the field is explicitly optional', () {
      expect(AppValidators.email('', required: false), isNull);
      expect(AppValidators.password(null, required: false), isNull);
      expect(AppValidators.saudiPhone('', required: false), isNull);
      expect(AppValidators.latitude('', required: false), isNull);
    });
  });

  group('AppValidators.minLength', () {
    test('should return null when value meets minimum length', () {
      expect(AppValidators.minLength('hello', 3), isNull);
    });

    test('should return MinLengthError carrying the bound', () {
      final error = AppValidators.minLength('he', 3);
      expect(error, isA<MinLengthError>());
      expect((error! as MinLengthError).min, 3);
    });
  });

  group('AppValidators.maxLength', () {
    test('should return null when value does not exceed maximum length', () {
      expect(AppValidators.maxLength('hello', 8), isNull);
    });

    test('should return MaxLengthError carrying the bound', () {
      final error = AppValidators.maxLength('helloworld', 8);
      expect(error, isA<MaxLengthError>());
      expect((error! as MaxLengthError).max, 8);
    });
  });

  group('AppValidators.numeric', () {
    test('should return null when value is numeric', () {
      expect(AppValidators.numeric('123'), isNull);
      expect(AppValidators.numeric('-123.45'), isNull);
    });

    test('should return NotNumericError when value is non-numeric', () {
      expect(AppValidators.numeric('123a'), isA<NotNumericError>());
      expect(AppValidators.numeric('abc'), isA<NotNumericError>());
    });
  });

  group('AppValidators.arabicOnly', () {
    test('should return null when value contains Arabic text only', () {
      expect(AppValidators.arabicOnly('مرحبا بك'), isNull);
    });

    test('should return NotArabicError when value contains Latin text', () {
      expect(AppValidators.arabicOnly('مرحبا بك welcome'), isA<NotArabicError>());
    });
  });

  group('AppValidators.latitude', () {
    test('should return null when latitude is between -90.0 and 90.0', () {
      expect(AppValidators.latitude('0.0'), isNull);
      expect(AppValidators.latitude('-45.123'), isNull);
      expect(AppValidators.latitude('90.0'), isNull);
      expect(AppValidators.latitude('-90.0'), isNull);
    });

    test('should return InvalidLatitudeError outside the boundaries', () {
      expect(AppValidators.latitude('-90.1'), isA<InvalidLatitudeError>());
      expect(AppValidators.latitude('91.0'), isA<InvalidLatitudeError>());
      expect(AppValidators.latitude('abc'), isA<InvalidLatitudeError>());
    });
  });

  group('AppValidators.longitude', () {
    test('should return null when longitude is between -180.0 and 180.0', () {
      expect(AppValidators.longitude('0.0'), isNull);
      expect(AppValidators.longitude('-120.45'), isNull);
      expect(AppValidators.longitude('180.0'), isNull);
      expect(AppValidators.longitude('-180.0'), isNull);
    });

    test('should return InvalidLongitudeError outside the boundaries', () {
      expect(AppValidators.longitude('-180.1'), isA<InvalidLongitudeError>());
      expect(AppValidators.longitude('180.5'), isA<InvalidLongitudeError>());
      expect(AppValidators.longitude('xyz'), isA<InvalidLongitudeError>());
    });
  });

  group('AppValidators.saudiPlateNumber', () {
    test('should return null when Saudi plate number matches format', () {
      expect(AppValidators.saudiPlateNumber('1234 abc'), isNull);
      expect(AppValidators.saudiPlateNumber('999 xyz'), isNull);
      expect(AppValidators.saudiPlateNumber('123أبج'), isNull);
    });

    test('should return InvalidPlateNumberError when the format is wrong', () {
      expect(
        AppValidators.saudiPlateNumber('12345 abc'),
        isA<InvalidPlateNumberError>(),
      );
      expect(
        AppValidators.saudiPlateNumber('123 ab'),
        isA<InvalidPlateNumberError>(),
      );
      expect(
        AppValidators.saudiPlateNumber('abc 1234'),
        isA<InvalidPlateNumberError>(),
      );
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
      expect(result, isA<RequiredFieldError>());
      expect((result! as RequiredFieldError).fieldName, 'Email');
    });
  });
}
