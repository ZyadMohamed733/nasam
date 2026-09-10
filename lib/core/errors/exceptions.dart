sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.code,
    super.stackTrace,
  });

  /// Per-field messages from a 422 response, keyed by the server's field name.
  final Map<String, List<String>> fieldErrors;
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
