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
        case 400:
          return _validationExceptionFrom(err);
        case 401:
          // The API's own message distinguishes bad credentials / expired
          // session / revoked token and must be shown verbatim -- it is
          // always a plain string in the body for this backend. Fall back
          // to a generic message only when the body has none.
          return AuthException(
            message:
                _messageFrom(err.response?.data) ??
                'Your session has expired. Please log in again.',
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
          // The backend's message says what was not found ("no account
          // with that email") and is shown when present.
          return ServerException(
            message: _messageFrom(err.response?.data) ?? 'Resource not found.',
            code: '404',
            stackTrace: err.stackTrace,
          );
        case 429:
          return RateLimitException(
            message:
                _messageFrom(err.response?.data) ??
                'Too many attempts. Please try again later.',
            retryAfterSeconds: _retryAfterSecondsFrom(err),
            code: '429',
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

  /// Reads `message` off a JSON error body when it is a plain string.
  static String? _messageFrom(Object? body) {
    if (body is! Map) return null;
    final message = body['message'];
    return message is String ? message : null;
  }

  /// Builds a [ValidationException] from a `400` body. This backend (a
  /// NestJS `class-validator` pipe) sends `message` as either a single
  /// string (one business-rule failure, e.g. "email must be a valid email
  /// address") or an array of class-validator's default
  /// "`<field> <constraint>`" sentences (e.g. "username is required"). A
  /// per-field key is derived from each sentence's leading token so
  /// `AppTextField`s can still highlight their own error; a body that
  /// matches neither shape yields a generic validation failure rather than
  /// throwing -- a malformed error body must not mask the error itself.
  static ValidationException _validationExceptionFrom(DioException err) {
    final body = err.response?.data;
    final message = body is Map ? body['message'] : null;

    if (message is List) {
      final sentences = message.whereType<String>().toList();
      if (sentences.isNotEmpty) {
        final fieldErrors = <String, List<String>>{};
        for (final sentence in sentences) {
          (fieldErrors[_fieldKeyFrom(sentence)] ??= []).add(sentence);
        }
        return ValidationException(
          message: sentences.first,
          fieldErrors: fieldErrors,
          code: '400',
          stackTrace: err.stackTrace,
        );
      }
    } else if (message is String) {
      return ValidationException(
        message: message,
        fieldErrors: {
          _fieldKeyFrom(message): [message],
        },
        code: '400',
        stackTrace: err.stackTrace,
      );
    }

    return ValidationException(
      message: 'Validation failed.',
      code: '400',
      stackTrace: err.stackTrace,
    );
  }

  /// `"username is required"` -> `"username"` -- class-validator's default
  /// message format always leads with the property name.
  static String _fieldKeyFrom(String sentence) {
    final firstSpace = sentence.indexOf(' ');
    return firstSpace == -1 ? sentence : sentence.substring(0, firstSpace);
  }

  /// Prefers the `Retry-After` header (seconds); falls back to parsing
  /// "... N minute(s) ..." out of the error message when the header is
  /// missing, since this API's 429 bodies say the wait in minutes in text.
  static int? _retryAfterSecondsFrom(DioException err) {
    final header = err.response?.headers.value('retry-after');
    final headerSeconds = header == null ? null : int.tryParse(header);
    if (headerSeconds != null) return headerSeconds;

    final message = _messageFrom(err.response?.data);
    if (message == null) return null;
    final match = RegExp(r'(\d+)\s*minute').firstMatch(message);
    if (match == null) return null;
    final minutes = int.tryParse(match.group(1)!);
    return minutes == null ? null : minutes * 60;
  }
}
