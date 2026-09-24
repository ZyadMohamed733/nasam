// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nasam';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please log in again.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get emptyState => 'No data available.';

  @override
  String validationRequired(String field) {
    return '$field is required.';
  }

  @override
  String get validationRequiredGeneric => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Please enter a valid email address.';

  @override
  String get validationPasswordWeak =>
      'Password must be at least 8 characters with uppercase, lowercase, number and symbol.';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get validationInvalidPhone =>
      'Please enter a valid Saudi phone number.';

  @override
  String validationMinLength(int min) {
    return 'Minimum length is $min characters.';
  }

  @override
  String validationMaxLength(int max) {
    return 'Maximum length is $max characters.';
  }

  @override
  String get validationNotNumeric => 'Value must be numeric.';

  @override
  String get validationNotArabic => 'Only Arabic characters are allowed.';

  @override
  String get validationInvalidLatitude =>
      'Latitude must be between -90.0 and 90.0.';

  @override
  String get validationInvalidLongitude =>
      'Longitude must be between -180.0 and 180.0.';

  @override
  String get validationInvalidPlateNumber =>
      'Please enter a valid Saudi plate number.';

  @override
  String get relativeJustNow => 'Just now';

  @override
  String relativeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String vehicleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
      zero: 'No vehicles',
    );
    return '$_temp0';
  }

  @override
  String otpExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get otpExpired => 'The code has expired.';

  @override
  String get otpNotReceived => 'Didn\'t receive the code?';

  @override
  String get otpResend => 'Resend code';

  @override
  String get onboardingTitle1 => 'Every vehicle, on one screen';

  @override
  String get onboardingBody1 =>
      'Follow your whole fleet live, wherever it is on the road.';

  @override
  String get onboardingTitle2 => 'Routes that plan themselves';

  @override
  String get onboardingBody2 =>
      'See the fastest way through, and know the moment it changes.';

  @override
  String get onboardingTitle3 => 'Your team, in step';

  @override
  String get onboardingBody3 =>
      'Share plans and updates so everyone is working from the same picture.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to follow your fleet.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'name@company.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Your password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send you a code.';

  @override
  String get forgotPasswordSubmit => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String get otpSubtitle =>
      'We sent a six-digit code to your registered email address.';

  @override
  String get forgotPasswordCheckEmailTitle => 'Check your email';

  @override
  String get forgotPasswordCheckEmailSubtitle =>
      'If an account exists for that email address, we\'ve sent a password reset link to it.';

  @override
  String get otpSubmit => 'Verify';

  @override
  String get newPasswordTitle => 'Choose a new password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordConfirmLabel => 'Confirm password';

  @override
  String get newPasswordSubmit => 'Save password';

  @override
  String get newPasswordDone =>
      'Your password has been changed. Sign in to continue.';

  @override
  String passwordRuleMinLength(int count) {
    return 'At least $count characters';
  }

  @override
  String get passwordRuleMatches => 'Passwords match';

  @override
  String get passwordRuleUppercase => 'One uppercase letter';

  @override
  String get passwordRuleLowercase => 'One lowercase letter';

  @override
  String get passwordRuleDigit => 'One number';

  @override
  String get passwordRuleSpecialCharacter => 'One special character';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginUsernameHint => 'Username';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get newPasswordSubtitle =>
      'Enter your details to create a new password.';

  @override
  String get trackingTitle => 'Tracking dashboard';

  @override
  String get trackingShow => 'Show';

  @override
  String get trackingAll => 'All';

  @override
  String get trackingMoving => 'Moving';

  @override
  String get trackingIdle => 'Temporarily stopped';

  @override
  String get trackingStopped => 'Stopped';

  @override
  String get trackingOffline => 'Offline';

  @override
  String get trackingSearch => 'Search';

  @override
  String get trackingSystems => 'Systems';

  @override
  String get trackingFleet => 'Fleet';

  @override
  String get trackingPoi => 'Points of interest';

  @override
  String get trackingGeofences => 'Geofences';

  @override
  String get trackingAssignments => 'Assignments';

  @override
  String get trackingSettings => 'Settings';

  @override
  String get trackingAsset => 'Asset';

  @override
  String get trackingNotifications => 'Notifications';

  @override
  String get trackingLayers => 'Layers';

  @override
  String get trackingZoomIn => 'Zoom in';

  @override
  String get trackingZoomOut => 'Zoom out';

  @override
  String get trackingMenu => 'Menu';

  @override
  String get trackingLogout => 'Logout';

  @override
  String get assetDetailsInformation => 'Information';

  @override
  String get assetDetailsTracking => 'Tracking';

  @override
  String get assetDetailsLocation => 'Location';

  @override
  String get assetDetailsAssets => 'Sensors';

  @override
  String get assetDetailsNotifications => 'Notifications';

  @override
  String get assetDetailsName => 'Asset name';

  @override
  String get assetDetailsType => 'Type';

  @override
  String get assetDetailsCompany => 'Company';

  @override
  String get assetDetailsId => 'Asset ID';

  @override
  String get assetDetailsAssignedPerson => 'Assigned person';

  @override
  String get assetDetailsManager => 'Manager';

  @override
  String get assetDetailsSpeed => 'Speed';

  @override
  String get assetDetailsDuration => 'Duration';

  @override
  String get assetDetailsStatus => 'Asset status';

  @override
  String get assetDetailsConnection => 'Last connection';

  @override
  String get assetDetailsGpsTime => 'GPS time';

  @override
  String get assetDetailsDistance => 'Distance';

  @override
  String get assetDetailsFuel => 'Fuel';

  @override
  String get assetDetailsIdleTime => 'Idle time';

  @override
  String get assetDetailsTankLevel => 'Tank level';

  @override
  String get assetDetailsTemperature => 'Temperature';

  @override
  String get assetDetailsWeight => 'Weight';

  @override
  String get assetDetailsSensorHistory => 'Sensor history';

  @override
  String get assetDetailsDownload => 'Download';

  @override
  String get assetDetailsFuelUsage => 'Fuel usage';

  @override
  String get assetDetailsDoor => 'Door';

  @override
  String get assetDetailsEngine => 'Engine';

  @override
  String get assetDetailsAddress => 'Address';

  @override
  String get assetDetailsAlertName => 'Alert name';

  @override
  String get assetDetailsAlertType => 'Alert type';

  @override
  String get assetDetailsAlertSpeed => 'Speed';

  @override
  String get assetDetailsAlertDate => 'Date';

  @override
  String get assetDetailsAlertLocation => 'Location';

  @override
  String get assetDetailsRunning => 'Running';

  @override
  String get assetDetailsOpen => 'Open';

  @override
  String get assetDetailsClosed => 'Closed';

  @override
  String get assetDetailsOn => 'On';

  @override
  String get assetDetailsOff => 'Off';

  @override
  String get assetDetailsSpeedingAlert => 'Speed limit exceeded';

  @override
  String get assetDetailsStoppedAlert => 'Asset stopped';

  @override
  String get assetDetailsGeofenceAlert => 'Geofence entered';

  @override
  String get assetDetailsEmptyAlerts => 'No notifications for this asset.';

  @override
  String get assetPlaybackTitle => 'Playback';

  @override
  String get assetPlaybackFrom => 'From date';

  @override
  String get assetPlaybackTo => 'To date';

  @override
  String get assetPlaybackStart => 'Start playback';

  @override
  String get assetPlaybackPause => 'Pause playback';

  @override
  String get assetPlaybackPlay => 'Play segment';

  @override
  String get assetPlaybackEmpty => 'No playback records for this date range.';

  @override
  String get assetPlaybackDistance => 'Distance';

  @override
  String get assetPlaybackMaxSpeed => 'Maximum speed';

  @override
  String get assetPlaybackDuration => 'Duration';

  @override
  String get assetPlaybackKilometers => 'km';

  @override
  String get assetPlaybackKilometersPerHour => 'km/h';

  @override
  String get assetPlaybackMinutes => 'min';

  @override
  String get assetNotFound => 'This asset could not be found.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get trackingNoMatches => 'No assets match your search.';

  @override
  String get trackingClearFilters => 'Clear filters';

  @override
  String get trackingCollapse => 'Collapse list';

  @override
  String trackingStatusChip(String status, int count) {
    return '$status: $count';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get trackingActionCamera => 'Live camera';

  @override
  String get trackingActionChat => 'Message';

  @override
  String get trackingActionLocate => 'Show on map';

  @override
  String get trackingActionCall => 'Call';

  @override
  String get trackingActionEmail => 'Email';

  @override
  String unitSpeedKph(String value) {
    return '$value km/h';
  }

  @override
  String unitDistanceKm(String value) {
    return '$value km';
  }

  @override
  String unitWeightKg(String value) {
    return '$value kg';
  }

  @override
  String unitHours(String value) {
    return '$value h';
  }

  @override
  String unitCelsius(String value) {
    return '$value °C';
  }

  @override
  String unitPercent(String value) {
    return '$value%';
  }

  @override
  String durationMinutesSeconds(String minutes, String seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get userTypeAdmin => 'System administrator';

  @override
  String get userTypeEmployee => 'Employee';

  @override
  String get userTypeClientAdmin => 'Client administrator';

  @override
  String get userTypeClientEmployee => 'Client employee';

  @override
  String unitMillivolts(String value) {
    return '$value mV';
  }
}
