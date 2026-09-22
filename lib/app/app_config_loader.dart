import '../core/constants/app_constants.dart';
import '../core/utils/app_logger.dart';
import 'app_config.dart';

/// Builds the [AppConfig] for a flavor from compile-time configuration.
///
/// URLs arrive via `--dart-define-from-file=config/<flavor>.json` rather than a
/// bundled `.env` asset. A `.env` listed under `flutter: assets:` ships inside
/// every build, so a release APK could be unzipped to read the dev, staging and
/// production hostnames as plain text. Compiled-in values are not handed to the
/// reader as a file.
abstract final class AppConfigLoader {
  static const String _baseUrl = String.fromEnvironment('BASE_URL');
  static const String _wsUrl = String.fromEnvironment('WS_URL');
  static const String _flavorName = String.fromEnvironment('FLAVOR');

  static AppConfig forFlavor(Flavor flavor) => build(
    flavor: flavor,
    baseUrl: _baseUrl,
    wsUrl: _wsUrl,
    configuredFlavor: _flavorName,
  );

  /// Split out from [forFlavor] so the validation is reachable from tests;
  /// `String.fromEnvironment` is const-folded and cannot be varied at runtime.
  static AppConfig build({
    required Flavor flavor,
    required String baseUrl,
    required String wsUrl,
    required String configuredFlavor,
  }) {
    if (baseUrl.isEmpty || wsUrl.isEmpty) {
      throw StateError(
        'Missing BASE_URL or WS_URL for the "${flavor.name}" flavor.\n'
        '\n'
        'These are compile-time defines, so they have to be supplied to the '
        'build — a hot restart cannot add them.\n'
        '\n'
        'From the CLI:\n'
        '  flutter run --flavor ${flavor.name} '
        '-t lib/main_${flavor.name}.dart '
        '--dart-define-from-file=config/${flavor.name}.json\n'
        '\n'
        'From an IDE, pick the "nasam ${flavor.name}" configuration rather '
        'than running the file directly: Android Studio and IntelliJ read '
        '.run/nasam_${flavor.name}.run.xml, VS Code reads .vscode/launch.json. '
        'Running lib/main_${flavor.name}.dart with no configuration is what '
        'produces this error.',
      );
    }

    // Guards running the prod entrypoint against a dev config file, which no
    // amount of URL checking downstream would catch.
    if (configuredFlavor != flavor.name) {
      throw StateError(
        'Flavor mismatch: entrypoint is "${flavor.name}" but the config file '
        'declares "$configuredFlavor". Use config/${flavor.name}.json.',
      );
    }

    if (!hostsAgree(baseUrl, wsUrl)) {
      // Warning-only: the dev API and the (still-placeholder) WS host are
      // expected to disagree for now. Flip back to a hard StateError once
      // WS_URL points at a real socket host for this environment.
      AppLogger.w(
        'API host "${Uri.parse(baseUrl).host}" and socket host '
        '"${Uri.parse(wsUrl).host}" are not from the same environment.',
      );
    }

    return AppConfig(
      flavor: flavor,
      appName: _appNameFor(flavor),
      baseUrl: baseUrl,
      wsUrl: wsUrl,
    );
  }

  /// Makes an API/socket environment mismatch impossible rather than merely
  /// fixed: `api-dev.nasam.app` with `wss://ws.nasam.app` fails here.
  static bool hostsAgree(String baseUrl, String wsUrl) {
    final apiHost = Uri.parse(baseUrl).host;
    final socketHost = Uri.parse(wsUrl).host;
    if (apiHost.isEmpty || socketHost.isEmpty) return false;
    return _environmentTag(apiHost) == _environmentTag(socketHost) &&
        _domain(apiHost) == _domain(socketHost);
  }

  /// `api-dev.nasam.app` -> `dev`; `api.nasam.app` -> `` (production).
  static String _environmentTag(String host) {
    final firstLabel = host.split('.').first;
    final dash = firstLabel.indexOf('-');
    return dash == -1 ? '' : firstLabel.substring(dash + 1);
  }

  /// Everything after the first label: `api-dev.nasam.app` -> `nasam.app`.
  static String _domain(String host) => host.split('.').skip(1).join('.');

  static String _appNameFor(Flavor flavor) => switch (flavor) {
    Flavor.dev => AppConstants.devAppName,
    Flavor.staging => AppConstants.stageAppName,
    Flavor.prod => AppConstants.appName,
  };
}
