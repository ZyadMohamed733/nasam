import 'exceptions.dart';
import 'failures.dart';

/// Translates data-layer [AppException]s into the domain's [Failure] types.
/// Repositories call this at the boundary where data becomes domain.
abstract final class FailureMapper {
  /// Exhaustive over the sealed [AppException] hierarchy on purpose: adding a
  /// new exception without a matching failure must be a compile error, not a
  /// silent fall-through to [UnknownFailure].
  static Failure fromException(AppException exception) => switch (exception) {
    NetworkException() => NetworkFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    ServerException() => ServerFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    CacheException() => CacheFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    ValidationException() => ValidationFailure(
      message: exception.message,
      fieldErrors: exception.fieldErrors,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    AuthException() => AuthFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    PermissionException() => PermissionFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    TimeoutException() => TimeoutFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
    UnknownException() => UnknownFailure(
      message: exception.message,
      code: exception.code,
      stackTrace: exception.stackTrace,
    ),
  };
}
