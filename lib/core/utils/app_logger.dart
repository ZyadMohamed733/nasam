import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Emits debug/info/warning only in debug builds; errors always pass, so a
/// crash reporter attached to [AppLogger.e] still receives them in release.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level.index >= Level.error.index) return true;
    return kDebugMode;
  }
}

class AppLogger {
  // An explicit filter rather than logger's default DevelopmentFilter, which
  // silences everything in release -- including errors.
  static final Logger _logger = Logger(
    filter: _AppLogFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void d(String message) {
    _logger.d(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void w(String message) {
    _logger.w(message);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
