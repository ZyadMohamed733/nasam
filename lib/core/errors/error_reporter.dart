import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

/// Where an uncaught error was observed, so a crash report can say which
/// boundary let it through.
enum ErrorSource {
  /// Thrown during build/layout/paint.
  flutterFramework,

  /// An unhandled async error on the platform dispatcher.
  platformDispatcher,

  /// An unhandled error inside the guarded zone around `runApp`.
  zone,

  /// Thrown inside a Bloc's event handler.
  bloc,
}

/// The single sink every uncaught error funnels into.
///
/// Previously nothing survived to production: there were no
/// `FlutterError.onError`, `PlatformDispatcher.onError`, `runZonedGuarded` or
/// `ErrorWidget.builder` hooks anywhere, and `AppBlocObserver.onError` logged
/// through `logger`, whose default `DevelopmentFilter` drops everything in
/// release.
void reportError(
  Object error,
  StackTrace stackTrace, {
  required ErrorSource source,
  String? context,
}) {
  AppLogger.e(
    'Uncaught error [${source.name}]${context == null ? '' : ' — $context'}',
    error: error,
    stackTrace: stackTrace,
  );

  // TODO(nasam): attach a crash reporter here — Crashlytics
  // (FirebaseCrashlytics.instance.recordError) or Sentry
  // (Sentry.captureException). Everything already routes through this one
  // function, so wiring one up is a change in this file alone.
  if (kReleaseMode) {
    // Intentionally empty until a reporter is chosen: the log call above is
    // the only sink, and AppLogger keeps its filter in release.
  }
}
