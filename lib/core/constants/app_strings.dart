class AppStrings {
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserLocale = 'user_locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserData = 'user_data';
  static const String keyOnboardingSeen = 'onboarding_seen';

  /// SharedPreferences flag: set once the keychain has been checked for a
  /// previous install's session. See `SecureStorageService.open`.
  static const String keyAuthStorageInitialised = 'auth_storage_initialised';

  // Network & Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String valueJsonType = 'application/json';

  // WebSocket Events
  static const String wsEventLocationUpdate = 'location_update';
  static const String wsEventVehicleStatus = 'vehicle_status';
  static const String wsEventAlertTriggered = 'alert_triggered';
}
