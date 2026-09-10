sealed class Failure {
  const Failure({required this.message, this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code,
    super.stackTrace,
  });

  /// Per-field messages from a 422 response, keyed by the server's field name.
  final Map<String, List<String>> fieldErrors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          _fieldErrorsEqual(fieldErrors, other.fieldErrors);

  @override
  int get hashCode =>
      message.hashCode ^ code.hashCode ^ _fieldErrorsHash(fieldErrors);
}

bool _fieldErrorsEqual(
  Map<String, List<String>> a,
  Map<String, List<String>> b,
) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    final other = b[entry.key];
    if (other == null || other.length != entry.value.length) return false;
    for (var i = 0; i < other.length; i++) {
      if (other[i] != entry.value[i]) return false;
    }
  }
  return true;
}

int _fieldErrorsHash(Map<String, List<String>> fieldErrors) {
  var hash = 0;
  for (final entry in fieldErrors.entries) {
    // XOR keeps the result order-independent, as map iteration order is not
    // part of equality here.
    hash ^= entry.key.hashCode ^ Object.hashAll(entry.value);
  }
  return hash;
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
