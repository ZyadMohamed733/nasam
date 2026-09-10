import 'validation_error.dart';

/// Field validators returning a typed [ValidationError] rather than a message,
/// so the same rule renders in English or Arabic depending on where it is shown.
///
/// Every validator takes `required` (default true): a blank value is a
/// [RequiredFieldError], not a pass. Pass `required: false` for optional fields.
class AppValidators {
  /// Email: RFC-compliant regex
  static ValidationError? email(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );
    return regex.hasMatch(value!) ? null : const InvalidEmailError();
  }

  /// Password: min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char
  static ValidationError? password(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    if (value!.length < 8) return const PasswordTooWeakError();

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecial) {
      return const PasswordTooWeakError();
    }
    return null;
  }

  /// Confirm password match
  static ValidationError? confirmPassword(String? value, String original) {
    return value != original ? const PasswordMismatchError() : null;
  }

  /// Phone: Saudi format (+966 or 05xxxxxxxx or 5xxxxxxxx)
  static ValidationError? saudiPhone(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    // Saudi numbers start with +9665..., 009665..., 05... or 5... then 8 digits
    final regex = RegExp(r'^(?:\+966|00966|0)?5[0-9]{8}$');
    return regex.hasMatch(value!.trim()) ? null : const InvalidPhoneError();
  }

  /// Required field (non-null, non-empty, non-whitespace)
  static ValidationError? required(String? value, {String? fieldName}) {
    return _isBlank(value) ? RequiredFieldError(fieldName: fieldName) : null;
  }

  static ValidationError? minLength(
    String? value,
    int min, {
    bool required = true,
  }) {
    if (_isBlank(value)) return _blankError(required: required);
    return value!.length < min ? MinLengthError(min) : null;
  }

  static ValidationError? maxLength(
    String? value,
    int max, {
    bool required = true,
  }) {
    if (_isBlank(value)) return _blankError(required: required);
    return value!.length > max ? MaxLengthError(max) : null;
  }

  static ValidationError? numeric(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);
    return double.tryParse(value!.trim()) == null
        ? const NotNumericError()
        : null;
  }

  /// Arabic text only (Unicode range U+0600-U+06FF and spaces)
  static ValidationError? arabicOnly(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    final regex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return regex.hasMatch(value!) ? null : const NotArabicError();
  }

  /// GPS latitude: -90.0 to 90.0
  static ValidationError? latitude(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    final lat = double.tryParse(value!.trim());
    return (lat == null || lat < -90.0 || lat > 90.0)
        ? const InvalidLatitudeError()
        : null;
  }

  /// GPS longitude: -180.0 to 180.0
  static ValidationError? longitude(String? value, {bool required = true}) {
    if (_isBlank(value)) return _blankError(required: required);

    final lng = double.tryParse(value!.trim());
    return (lng == null || lng < -180.0 || lng > 180.0)
        ? const InvalidLongitudeError()
        : null;
  }

  /// Vehicle plate number (Saudi format): 1-4 digits then 3 Arabic or Latin
  /// letters, e.g. `1234 أ ب ج`.
  static ValidationError? saudiPlateNumber(
    String? value, {
    bool required = true,
  }) {
    if (_isBlank(value)) return _blankError(required: required);

    final regex = RegExp(r'^[0-9]{1,4}\s?[a-zA-Z\u0600-\u06FF]{3}$');
    return regex.hasMatch(value!.trim())
        ? null
        : const InvalidPlateNumberError();
  }

  /// Runs validators in order and returns the first error.
  static ValidationError? compose(
    String? value,
    List<ValidationError? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  static ValidationError? _blankError({required bool required}) =>
      required ? const RequiredFieldError() : null;
}
