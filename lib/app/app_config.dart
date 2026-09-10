enum Flavor { dev, staging, prod }

/// Per-flavor configuration, resolved once at startup and injected.
///
/// Previously these were `late static` fields, which meant `DioClient` read
/// `AppConfig.baseUrl` before `AppConfig.configure()` had necessarily run --
/// safe only because Dio happened to be a lazy singleton. As an injected
/// instance the ordering is enforced by construction rather than by luck.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
    required this.wsUrl,
  });

  final Flavor flavor;
  final String baseUrl;
  final String appName;
  final String wsUrl;

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
