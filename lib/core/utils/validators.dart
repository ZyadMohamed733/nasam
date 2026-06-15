class AppValidators {
  /// Email: RFC-compliant regex
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Password: min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char
  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecial) {
      return 'Password must contain uppercase, lowercase, number, and special character.';
    }
    return null;
  }

  /// Confirm password match
  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Phone: Saudi format (+966 or 05xxxxxxxx or 5xxxxxxxx)
  static String? saudiPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleanValue = value.trim();
    // Saudi numbers start with +9665..., 009665..., 05... or 5... followed by 8 digits
    final regex = RegExp(r'^(?:\+966|00966|0)?5[0-9]{8}$');
    if (!regex.hasMatch(cleanValue)) {
      return 'Please enter a valid Saudi phone number.';
    }
    return null;
  }

  /// Required field (non-null, non-empty, non-whitespace)
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required.' : 'This field is required.';
    }
    return null;
  }

  /// Min length
  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return 'Minimum length is $min characters.';
    }
    return null;
  }

  /// Max length
  static String? maxLength(String? value, int max) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return 'Maximum length is $max characters.';
    }
    return null;
  }

  /// Numeric only
  static String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Value must be numeric.';
    }
    return null;
  }

  /// Arabic text only (Unicode range \u0600-\u06FF and spaces)
  static String? arabicOnly(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\u0600-\u06FF\s]+$');
    if (!regex.hasMatch(value)) {
      return 'Only Arabic characters are allowed.';
    }
    return null;
  }

  /// GPS latitude: -90.0 to 90.0
  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final lat = double.tryParse(value.trim());
    if (lat == null || lat < -90.0 || lat > 90.0) {
      return 'Latitude must be between -90.0 and 90.0.';
    }
    return null;
  }

  /// GPS longitude: -180.0 to 180.0
  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final lng = double.tryParse(value.trim());
    if (lng == null || lng < -180.0 || lng > 180.0) {
      return 'Longitude must be between -180.0 and 180.0.';
    }
    return null;
  }

  /// Vehicle plate number (Saudi format)
  /// Saudi plates have 1 to 4 digits and 3 Arabic letters.
  /// Example: 1234 أ ب ج or English equivalent. Let's make it accept alphanumeric characters and spaces.
  static String? saudiPlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    // Match 1 to 4 digits followed by optional space, then 3 Arabic letters, or English letters (A-Z)
    final regex = RegExp(r'^[0-9]{1,4}\s?[a-zA-Z\u0600-\u06FF]{3}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid Saudi plate number.';
    }
    return null;
  }

  /// Compose multiple validators (runs all, returns first error)
  static String? compose(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
