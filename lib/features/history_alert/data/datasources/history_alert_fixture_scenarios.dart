/// Static response scenarios for exercising alert history on a device.
/// Change `FakeHistoryDatasource.deviceTestScenario` to one of these values.
abstract final class HistoryAlertFixtureScenarios {
  static const String success = 'success';
  static const String empty = 'empty';
  static const String serverError = 'serverError';
  static const String networkError = 'networkError';
  static const String timeout = 'timeout';
  static const String unauthorized = 'unauthorized';
  static const String rateLimit = 'rateLimit';
  static const String malformedPayload = 'malformedPayload';
  static const String unknownError = 'unknownError';
  static const String serverErrorOnce = 'serverErrorOnce';
  static const String detailsServerError = 'detailsServerError';
  static const String detailsNetworkError = 'detailsNetworkError';
  static const String detailsTimeout = 'detailsTimeout';
  static const String detailsUnauthorized = 'detailsUnauthorized';
  static const String detailsRateLimit = 'detailsRateLimit';
  static const String detailsMalformedPayload = 'detailsMalformedPayload';
  static const String detailsUnknownError = 'detailsUnknownError';
  static const String detailsServerErrorOnce = 'detailsServerErrorOnce';
}
