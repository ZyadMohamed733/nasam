class AppConstants {
  static const String devAppName = 'Nasam-Dev';
  static const String stageAppName = 'Nasam-Stage';
  static const String appName = 'Nasam';

  // Network connection configuration
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 15000;

  // Pagination parameters
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // WebSocket settings
  static const int wsBaseReconnectDelaySecs = 1;
  static const int wsMaxReconnectDelaySecs = 30;
  static const int wsPingIntervalSecs = 10;

  // Authentication configuration
  static const int tokenExpirySafetyMarginSecs = 60;
}