import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../errors/failures.dart';

@injectable
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapDioExceptionToFailure(err);

    // Attach our Failure object to the DioException's error property
    // so it can easily be intercepted and un-wrapped in Repository implementations.
    final updatedErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: failure,
      message: failure.message,
      stackTrace: err.stackTrace,
    );

    handler.next(updatedErr);
  }

  Failure _mapDioExceptionToFailure(DioException err) {
    // Connection or Network socket errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return NetworkFailure(
        message: 'No internet connection.',
        stackTrace: err.stackTrace,
      );
    }

    // Send or Receive timeouts
    if (err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure(
        message: 'Request timed out. Please try again.',
      );
    }

    // HTTP Response Status Codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      if (statusCode == 401) {
        return AuthFailure(
          message: 'Your session has expired. Please log in again.',
          code: '401',
          stackTrace: err.stackTrace,
        );
      } else if (statusCode == 403) {
        return PermissionFailure(
          message: 'You do not have permission to perform this action.',
          code: '403',
          stackTrace: err.stackTrace,
        );
      } else if (statusCode == 404) {
        return ServerFailure(
          message: 'Resource not found.',
          code: '404',
          stackTrace: err.stackTrace,
        );
      } else if (statusCode == 422) {
        return ValidationFailure(
          message: 'Validation failed.',
          code: '422',
          stackTrace: err.stackTrace,
        );
      } else if (statusCode >= 500 && statusCode < 600) {
        return ServerFailure(
          message: 'Server error. Please try again later.',
          code: statusCode.toString(),
          stackTrace: err.stackTrace,
        );
      }
    }

    // Fallback unknown failure
    return UnknownFailure(
      message: err.message ?? 'Something went wrong. Please try again.',
      stackTrace: err.stackTrace,
    );
  }
}
