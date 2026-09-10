import 'package:flutter/widgets.dart';
import '../extensions/context_extensions.dart';
import '../utils/validation_error.dart';

/// Resolves a [ValidationError] to a localised message at the widget layer,
/// which is the only place a [BuildContext] exists.
///
/// Exhaustive over the sealed hierarchy on purpose: a new error without a
/// message is a compile error, not an untranslated string on screen.
extension ValidationErrorL10n on ValidationError {
  String resolve(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RequiredFieldError(:final fieldName) => fieldName == null
          ? l10n.validationRequiredGeneric
          : l10n.validationRequired(fieldName),
      InvalidEmailError() => l10n.validationInvalidEmail,
      PasswordTooWeakError() => l10n.validationPasswordWeak,
      PasswordMismatchError() => l10n.validationPasswordsDoNotMatch,
      InvalidPhoneError() => l10n.validationInvalidPhone,
      MinLengthError(:final min) => l10n.validationMinLength(min),
      MaxLengthError(:final max) => l10n.validationMaxLength(max),
      NotNumericError() => l10n.validationNotNumeric,
      NotArabicError() => l10n.validationNotArabic,
      InvalidLatitudeError() => l10n.validationInvalidLatitude,
      InvalidLongitudeError() => l10n.validationInvalidLongitude,
      InvalidPlateNumberError() => l10n.validationInvalidPlateNumber,
    };
  }
}

/// Adapts a typed validator to the `String?` callback `TextFormField.validator`
/// expects, resolving the message against [context].
extension ValidationErrorResolver on BuildContext {
  String? Function(String?) validator(
    ValidationError? Function(String?) validate,
  ) {
    return (value) => validate(value)?.resolve(this);
  }
}
