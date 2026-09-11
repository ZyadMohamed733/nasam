import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app_bloc_observer.dart';
import 'app/app_config.dart';
import 'app/app_config_loader.dart';
import 'core/di/injection_container.dart';
import 'core/errors/error_reporter.dart';
import 'core/localization/l10n/app_localizations.dart';

/// Shared startup for every flavor entrypoint.
///
/// Run with the matching config, e.g.
/// `flutter run --flavor dev -t lib/main_dev.dart
/// --dart-define-from-file=config/dev.json`.
///
/// Everything happens inside a guarded zone so that no uncaught error — sync
/// or async, framework or platform — escapes without reaching [reportError].
Future<void> bootstrap(Flavor flavor, Widget Function() builder) async {
  await runZonedGuarded(
    () async {
      // 1. Ensure Flutter binding is initialized
      WidgetsFlutterBinding.ensureInitialized();

      _installErrorHandlers();

      // 2. Resolve this flavor's compile-time configuration, failing loudly if
      //    the config file was not passed or belongs to a different flavor
      final config = AppConfigLoader.forFlavor(flavor);

      // 3. Configure GetIt Dependency Injection with that configuration
      await configureDependencies(config);

      // 4. Set global Bloc Observer
      Bloc.observer = AppBlocObserver();

      runApp(builder());
    },
    (error, stackTrace) =>
        reportError(error, stackTrace, source: ErrorSource.zone),
  );
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    // Keep the console dump in debug; route everything to the one sink.
    FlutterError.presentError(details);
    reportError(
      details.exception,
      details.stack ?? StackTrace.current,
      source: ErrorSource.flutterFramework,
      context: details.context?.toDescription(),
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    reportError(error, stackTrace, source: ErrorSource.platformDispatcher);
    return true;
  };

  // The default red-on-grey error box leaks widget internals to users; in
  // release show a neutral surface instead.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const _ReleaseErrorSurface();
  }
}

class _ReleaseErrorSurface extends StatelessWidget {
  const _ReleaseErrorSurface();

  @override
  Widget build(BuildContext context) {
    // Localizations may be unavailable if the failure happened above the
    // MaterialApp, so fall back to a neutral English string.
    final message =
        AppLocalizations.of(context)?.errorGeneric ??
        'Something went wrong. Please try again.';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
