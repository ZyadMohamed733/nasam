import 'dart:io';

import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Translates transport-level [DioException]s into the app's [AppException]
/// hierarchy. Datasources call this so nothing Dio-shaped escapes the data
/// layer.
abstract final class ExceptionMapper {
  static AppException fromDioException(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return NetworkException(
        message: 'No internet connection.',
        stackTrace: err.stackTrace,
      );
    }

    if (err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return TimeoutException(
        message: 'Request timed out. Please try again.',
        stackTrace: err.stackTrace,
      );
    }

    if (err.type == DioExceptionType.cancel) {
      return UnknownException(
        message: 'Request was cancelled.',
        stackTrace: err.stackTrace,
      );
    }

    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 401:
          return AuthException(
            message: 'Your session has expired. Please log in again.',
            code: '401',
            stackTrace: err.stackTrace,
          );
        case 403:
          return PermissionException(
            message: 'You do not have permission to perform this action.',
            code: '403',
            stackTrace: err.stackTrace,
          );
        case 404:
          return ServerException(
            message: 'Resource not found.',
            code: '404',
            stackTrace: err.stackTrace,
          );
        case 422:
          return ValidationException(
            message: 'Validation failed.',
            fieldErrors: parseFieldErrors(err.response?.data),
            code: '422',
            stackTrace: err.stackTrace,
          );
      }

      if (statusCode >= 500 && statusCode < 600) {
        return ServerException(
          message: 'Server error. Please try again later.',
          code: statusCode.toString(),
          stackTrace: err.stackTrace,
        );
      }
    }

    return UnknownException(
      message: err.message ?? 'Something went wrong. Please try again.',
      stackTrace: err.stackTrace,
    );
  }

  /// Reads `{"errors": {"field_name": ["message"]}}` out of a 422 body.
  /// Anything that does not match that shape yields an empty map rather than
  /// throwing — a malformed error body must not mask the error itself.
  static Map<String, List<String>> parseFieldErrors(Object? body) {
    if (body is! Map) return const {};

    final errors = body['errors'];
    if (errors is! Map) return const {};

    final parsed = <String, List<String>>{};
    for (final entry in errors.entries) {
      final key = entry.key;
      if (key is! String) continue;

      final value = entry.value;
      if (value is List) {
        final messages = value.whereType<String>().toList();
        if (messages.isNotEmpty) parsed[key] = messages;
      } else if (value is String) {
        parsed[key] = [value];
      }
    }
    return parsed;
  }
}
