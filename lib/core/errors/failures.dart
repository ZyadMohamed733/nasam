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
    super.code,
    super.stackTrace,
  });
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
