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
    required this.tenant,
  });

  final Flavor flavor;
  final String baseUrl;
  final String appName;
  final String wsUrl;

  /// The `x-tenant` every API call is scoped to. Per flavor, from the config
  /// file — a native request without it is answered 404, not 401.
  final String tenant;

  /// Sent on every API request, the token refresh included, so the two Dio
  /// clients cannot drift apart.
  Map<String, String> get apiHeaders => {
    // Tells the backend to deliver the refresh token in the response body
    // instead of an HttpOnly cookie -- native clients have no cookie jar for
    // the API host to write into.
    'X-Client': 'mobile',
    'x-tenant': tenant,
  };

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
