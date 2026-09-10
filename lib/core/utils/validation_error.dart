/// The result of a failed validation, as a value rather than a message.
///
/// Validators are static and have no [BuildContext], so they cannot reach
/// `context.l10n`. Returning a typed error instead of a `String` moves the
/// translation to the widget layer, where the context exists — see
/// `ValidationErrorL10n.resolve`.
sealed class ValidationError {
  const ValidationError();
}

class RequiredFieldError extends ValidationError {
  const RequiredFieldError({this.fieldName});

  /// Already-localised field label, when the caller has one.
  final String? fieldName;
}

class InvalidEmailError extends ValidationError {
  const InvalidEmailError();
}

class PasswordTooWeakError extends ValidationError {
  const PasswordTooWeakError();
}

class PasswordMismatchError extends ValidationError {
  const PasswordMismatchError();
}

class InvalidPhoneError extends ValidationError {
  const InvalidPhoneError();
}

class MinLengthError extends ValidationError {
  const MinLengthError(this.min);
  final int min;
}

class MaxLengthError extends ValidationError {
  const MaxLengthError(this.max);
  final int max;
}

class NotNumericError extends ValidationError {
  const NotNumericError();
}

class NotArabicError extends ValidationError {
  const NotArabicError();
}

class InvalidLatitudeError extends ValidationError {
  const InvalidLatitudeError();
}

class InvalidLongitudeError extends ValidationError {
  const InvalidLongitudeError();
}

class InvalidPlateNumberError extends ValidationError {
  const InvalidPlateNumberError();
}
