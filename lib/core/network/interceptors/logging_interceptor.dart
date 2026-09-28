import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../utils/app_logger.dart';

/// Request/response logging, debug builds only.
///
/// Every handler returns early when `!kDebugMode` so the log strings are never
/// even built in release — the previous version logged full request bodies,
/// which put login passwords and refresh tokens into the log verbatim, and
/// masked only an exactly-cased `Authorization` header.
@injectable
class LoggingInterceptor extends Interceptor {
  /// Matched case-insensitively against header names and JSON body keys.
  static const List<String> _sensitiveKeys = [
    'authorization',
    'password',
    'token',
    'refreshtoken',
    'refresh_token',
    'accesstoken',
    'access_token',
    'otp',
    'pin',
    'secret',
    'apikey',
    'api_key',
  ];

  /// Matched only as the whole key, because as a substring they would hide
  /// harmless fields: `code` is the one-time code sent to verify a login or
  /// a password reset, but `statusCode` and an asset's `code` are not
  /// secret.
  static const Set<String> _sensitiveExactKeys = {'code'};

  static const int _maxBodyChars = 2048;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    AppLogger.i('--> HTTP ${options.method} ${options.uri}');
    AppLogger.d('Headers: ${redact(options.headers)}');
    if (options.data != null) {
      AppLogger.d('Body: ${truncate(redact(options.data))}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kDebugMode) {
      handler.next(response);
      return;
    }

    AppLogger.i(
      '<-- HTTP ${response.statusCode} ${response.requestOptions.uri}',
    );
    if (response.data != null) {
      AppLogger.d('Response: ${truncate(redact(response.data))}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(err);
      return;
    }

    AppLogger.w(
      '<-- HTTP ERROR: ${err.message}\n'
      'URL: ${err.requestOptions.uri}\n'
      'Status: ${err.response?.statusCode}\n'
      'Response: ${truncate(redact(err.response?.data))}',
    );
    handler.next(err);
  }

  /// Replaces the value of any sensitive key, at any depth.
  @visibleForTesting
  static Object? redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _isSensitive(entry.key)
              ? '[REDACTED]'
              : redact(entry.value),
      };
    }
    if (value is List) {
      return value.map(redact).toList();
    }
    return value;
  }

  static bool _isSensitive(Object? key) {
    if (key is! String) return false;
    final normalised = key.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
    if (_sensitiveExactKeys.contains(normalised)) return true;
    return _sensitiveKeys.any(
      (sensitive) =>
          normalised.contains(sensitive.replaceAll(RegExp(r'[-_]'), '')),
    );
  }

  @visibleForTesting
  static String truncate(Object? value) {
    final text = value.toString();
    if (text.length <= _maxBodyChars) return text;
    return '${text.substring(0, _maxBodyChars)}… '
        '[truncated ${text.length - _maxBodyChars} chars]';
  }
}
