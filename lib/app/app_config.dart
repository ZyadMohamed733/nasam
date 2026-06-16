enum Flavor { dev, staging, prod }

class AppConfig {
  static late Flavor flavor;
  static late String baseUrl;
  static late String appName;
  static late String wsUrl;
  static void configure({
    required Flavor flavor,
    required String baseUrl,
    required String appName,
    required String wsUrl,
  }) {
    AppConfig.flavor = flavor;
    AppConfig.baseUrl = baseUrl;
    AppConfig.appName = appName;
    AppConfig.wsUrl = wsUrl;
  }

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStaging => flavor == Flavor.staging;
  static bool get isProd => flavor == Flavor.prod;
}