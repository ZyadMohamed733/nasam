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

  /// Caught and recovered from, so the user saw a degraded result rather
  /// than a failure — but it should not have happened.
  handled,

  /// Not thrown at all: the server answered in a shape the app was promised
  /// it never would. Nothing crashed, but someone needs to know.
  contract,
}

/// The server broke the API contract: a success that is missing what makes it
/// a success. Reported, not thrown to the user.
class ApiContractViolation implements Exception {
  const ApiContractViolation(this.endpoint, this.detail);

  final String endpoint;
  final String detail;

  @override
  String toString() => 'ApiContractViolation($endpoint): $detail';
}

/// [reportError] as a dependency, for code that reports rather than throws
/// and wants the report checked in tests.
class ErrorReporter {
  void report(
    Object error,
    StackTrace stackTrace, {
    required ErrorSource source,
    String? context,
  }) => reportError(error, stackTrace, source: source, context: context);
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
