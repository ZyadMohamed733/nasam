/// Named fixture responses for hands-on Playback checks on a device.
///
/// Set the list and map selectors on PlaybackFixtureDataSource independently.
abstract final class PlaybackFixtureScenarios {
  static const String success = 'success';
  static const String empty = 'empty';
  static const String segmentsEmpty = 'segmentsEmpty';
  static const String routeEmpty = 'routeEmpty';
  static const String slow = 'slow';
  static const String serverError = 'serverError';
  static const String networkError = 'networkError';
  static const String timeout = 'timeout';
  static const String unauthorized = 'unauthorized';
  static const String rateLimit = 'rateLimit';
  static const String malformedPayload = 'malformedPayload';
  static const String unknownError = 'unknownError';

  static const List<String> values = [
    success,
    empty,
    segmentsEmpty,
    routeEmpty,
    slow,
    serverError,
    networkError,
    timeout,
    unauthorized,
    rateLimit,
    malformedPayload,
    unknownError,
  ];
}
