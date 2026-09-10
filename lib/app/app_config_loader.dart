import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_constants.dart';
import 'app_config.dart';

/// Builds the [AppConfig] for a flavor from the loaded environment.
///
/// Kept separate from the entrypoints so the three `main_*.dart` files cannot
/// read `dotenv` before it is loaded — the ordering bug that made the previous
/// `late static` configuration work only by accident.
abstract final class AppConfigLoader {
  static AppConfig forFlavor(Flavor flavor) {
    return switch (flavor) {
      Flavor.dev => AppConfig(
        flavor: flavor,
        appName: AppConstants.devAppName,
        baseUrl: _require('DEV_BASE_URL'),
        wsUrl: _require('DEV_WS_URL'),
      ),
      Flavor.staging => AppConfig(
        flavor: flavor,
        appName: AppConstants.stageAppName,
        baseUrl: _require('STAGE_BASE_URL'),
        wsUrl: _require('STAGE_WS_URL'),
      ),
      Flavor.prod => AppConfig(
        flavor: flavor,
        appName: AppConstants.appName,
        baseUrl: _require('PROD_BASE_URL'),
        wsUrl: _require('PROD_WS_URL'),
      ),
    };
  }

  /// Fails loudly at startup rather than silently falling back to a hardcoded
  /// production URL, which is how every flavor ended up on the production
  /// socket.
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in the environment file. '
        'Every flavor must define its own API and socket URLs.',
      );
    }
    return value;
  }
}
