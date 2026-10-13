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
  String get save => 'Save';

  @override
  String get playbackTime => 'Time';

  @override
  String get morning => 'AM';

  @override
  String get evening => 'PM';

  @override
  String get hour => 'Hour';

  @override
  String get minute => 'Minute';

  @override
  String get playbackChooseDay => 'Choose day';

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
  String get trackingSettings => 'Settings';

  @override
  String get trackingAsset => 'Asset';

  @override
  String get trackingLastUpdated => 'Last updated · 2 min ago';

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
  String get manageAlerts => 'Manage alerts';

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
  String get alertAsset => 'Asset';

  @override
  String get alertType => 'Type';

  @override
  String get alertValue => 'Value';

  @override
  String get alertTime => 'Time';

  @override
  String get alertLocation => 'Location';

  @override
  String get alertDetailsSpeedInfo => 'Speed information';

  @override
  String get alertDetailsRecordedSpeed => 'Recorded speed';

  @override
  String get alertDetailsSpeedLimit => 'Speed limit';

  @override
  String get alertDetailsSubtitle => 'Alert details';

  @override
  String get alertFilter => 'Filter';

  @override
  String get alertFilterTitle => 'Filter alerts';

  @override
  String get alertFilterSubtitle =>
      'Choose the filters to show the matching alerts';

  @override
  String get alertFilterType => 'Alert type';

  @override
  String get alertFilterTypeAll => 'All';

  @override
  String get alertFilterTypeSpeed => 'Speed';

  @override
  String get alertFilterTypeSensor => 'Sensor';

  @override
  String get alertFilterTypeDowntime => 'Downtime';

  @override
  String get alertFilterDate => 'Date';

  @override
  String get alertFilterToday => 'Today';

  @override
  String get alertFilterYesterday => 'Yesterday';

  @override
  String get alertFilterLast7Days => 'Last 7 days';

  @override
  String get alertFilterLast30Days => 'Last 30 days';

  @override
  String get alertFilterCustomDate => 'Custom date';

  @override
  String get alertFilterFrom => 'From';

  @override
  String get alertFilterTo => 'To';

  @override
  String get alertFilterInvalidRange =>
      'To Date must be on or after From Date.';

  @override
  String get alertFilterApply => 'Apply';

  @override
  String get alertFilterReset => 'Reset';

  @override
  String get alertTypeGeofence => 'Geofence';

  @override
  String get alertTypeUnknown => 'Other';

  @override
  String get alertLocationUnavailable =>
      'Location is not available for this alert.';

  @override
  String get alertLoadMoreFailed => 'Couldn\'t load more alerts.';

  @override
  String get alertDetailsSensorInfo => 'Sensor details';

  @override
  String get alertDetailsSensor => 'Sensor';

  @override
  String get alertDetailsSensorType => 'Sensor type';

  @override
  String get alertDetailsTriggeredValue => 'Triggered value';

  @override
  String get alertDetailsCondition => 'Configured condition';

  @override
  String get alertDetailsDowntimeInfo => 'Downtime details';

  @override
  String get alertDetailsDuration => 'Duration';

  @override
  String alertDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get alertsNoSearchResults =>
      'No alerts were found for the selected criteria. Try changing your search or filters.';

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
  String get alertsLogUnavailable => 'No alerts log available';

  @override
  String get deviceAlertsEmpty =>
      'There are currently no alerts for this device';

  @override
  String get assetPlaybackTitle => 'Playback';

  @override
  String get playbackPrevious => 'Previous point';

  @override
  String get playbackNext => 'Next point';

  @override
  String get playbackInfo => 'Route information';

  @override
  String get playbackInfoAssetInformation => 'Asset information';

  @override
  String get playbackInfoDate => 'Date';

  @override
  String get playbackInfoStatus => 'Status';

  @override
  String get playbackInfoIgnition => 'Ignition';

  @override
  String get playbackInfoOdometer => 'Odometer';

  @override
  String get playbackInfoLocation => 'Location';

  @override
  String get playbackInfoSensors => 'Sensors';

  @override
  String get playbackInfoFuelLevel => 'Fuel level';

  @override
  String get playbackInfoHumidity => 'Humidity';

  @override
  String get playbackInfoMoving => 'Moving';

  @override
  String get playbackInfoIgnitionOn => 'On';

  @override
  String get playbackInfoIgnitionOff => 'Off';

  @override
  String get playbackBack => 'Back';

  @override
  String get assetPlaybackFrom => 'Start date';

  @override
  String get assetPlaybackTo => 'End date';

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

  @override
  String get resetCodeResent => 'A new code has been sent.';

  @override
  String get resetStartOver => 'Request a new code';

  @override
  String get drawerAlertsLog => 'Alerts log';

  @override
  String get drawerNoResults => 'No matching items';

  @override
  String get drawerClearSearch => 'Clear search';

  @override
  String get poiAdd => 'Add POI';

  @override
  String get poiUpload => 'Upload';

  @override
  String get poiDownload => 'Download';

  @override
  String get poiNoResults => 'No matching points of interest';

  @override
  String get poiEmpty => 'No points of interest yet';

  @override
  String get poiHide => 'Hide';

  @override
  String get poiLatitude => 'Latitude';

  @override
  String get poiLongitude => 'Longitude';

  @override
  String get poiDetails => 'Point of interest details';

  @override
  String get poiShowOnMap => 'Show on map';

  @override
  String get poiActions => 'Point of interest actions';

  @override
  String get poiEdit => 'Edit';

  @override
  String get poiDelete => 'Delete';

  @override
  String get poiCreateTitle => 'Create a point of interest';

  @override
  String get poiSubtitle => 'Enter the point details';

  @override
  String get poiBasicInfo => 'Basic information';

  @override
  String get poiName => 'Point of interest name';

  @override
  String get poiLocation => 'Location';

  @override
  String get poiIcon => 'Icon';

  @override
  String get poiLatitudeField => 'Latitude';

  @override
  String get poiLongitudeField => 'Longitude';

  @override
  String get poiSelectedCoordinates => 'Selected location coordinates';

  @override
  String get poiNameHint => 'Example: POI';

  @override
  String get poiIconHint => 'Choose an icon';

  @override
  String get poiIconLocation => 'Location';

  @override
  String get poiNotes => 'Notes';

  @override
  String get poiFuel => 'Fuel station';

  @override
  String get poiHospital => 'Hospital';

  @override
  String get poiLibrary => 'Library';

  @override
  String get poiCreate => 'Create POI';

  @override
  String get poiSave => 'Save changes';

  @override
  String get poiCancel => 'Cancel';

  @override
  String get poiRequired => 'This field is required';

  @override
  String get poiInvalidCoordinate => 'Enter a valid coordinate';

  @override
  String get poiNameLimit => 'Maximum 200 characters';

  @override
  String get poiNotesLimit => 'Maximum 2,000 characters';

  @override
  String get poiSelectLocation => 'Choose a location on the map';

  @override
  String get poiConfirmLocation => 'Confirm location';

  @override
  String get poiDeleteTitle => 'Delete point of interest';

  @override
  String get poiDeleteMessage =>
      'Are you sure you want to delete this point of interest?';

  @override
  String get poiNotFound => 'Point of interest not found';

  @override
  String get poiDiscardTitle => 'Discard changes?';

  @override
  String get poiDiscardMessage =>
      'Your changes have not been saved. Leave this screen?';

  @override
  String get poiDiscard => 'Discard';

  @override
  String get poiImportTitle => 'Upload points of interest';

  @override
  String get poiImportSubtitle =>
      'Upload multiple points using the Excel template';

  @override
  String get poiUploadStep => 'Upload file';

  @override
  String get poiValidate => 'Validate';

  @override
  String get poiPreview => 'Preview';

  @override
  String get poiConfirm => 'Confirm';

  @override
  String get poiTemplate => 'Download template';

  @override
  String get poiBrowse => 'Browse files';

  @override
  String get poiFileHint => 'Choose an Excel file to import';

  @override
  String get poiFileLimits =>
      'Supported format: .xlsx\nMaximum file size: 20 MB\nMaximum records: 5,000';

  @override
  String get poiValidationTitle => 'Validation results';

  @override
  String get poiPreviewTitle => 'Preview points of interest';

  @override
  String get poiValid => 'Valid';

  @override
  String get poiInvalid => 'Invalid';

  @override
  String get poiDuplicate => 'Duplicate';

  @override
  String get poiAll => 'All';

  @override
  String get poiPrevious => 'Previous';

  @override
  String get poiValidOnly =>
      'Only valid records will be imported. Invalid or duplicate records will be skipped.';

  @override
  String get poiDropTitle => 'Drag files here or tap to browse';

  @override
  String poiDropHint(String format, int size) {
    return '$format, up to $size MB';
  }

  @override
  String get poiFormatLabel => 'Supported format:';

  @override
  String get poiMaxSizeLabel => 'Maximum file size:';

  @override
  String get poiMaxRecordsLabel => 'Maximum records:';

  @override
  String poiSizeMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get poiRemoveFile => 'Remove file';

  @override
  String poiValidationDescription(String fileName) {
    return 'Review the validation result for every record in $fileName';
  }

  @override
  String poiValidationSummary(int valid, int invalid) {
    return '$valid valid records are ready to import. $invalid records have errors and will not be imported.';
  }

  @override
  String get poiPreviewDescription =>
      'Review the valid points of interest before importing them.';

  @override
  String poiTotalRecords(int count) {
    return 'Total $count';
  }

  @override
  String get poiImportDoneDescription =>
      'Multiple points of interest were uploaded from the predefined Excel template';

  @override
  String get poiImportSucceeded => 'Imported';

  @override
  String get poiImportFailed => 'Failed';

  @override
  String get poiImportDuplicates => 'Duplicates';

  @override
  String get poiIssueNameRequired => 'Name is required';

  @override
  String get poiIssueNameTooLong => 'Name must be 200 characters or fewer';

  @override
  String get poiIssueLatitude => 'Latitude must be between -90 and 90';

  @override
  String get poiIssueLongitude => 'Longitude must be between -180 and 180';

  @override
  String get poiIssueIcon => 'Unknown icon';

  @override
  String get poiIssueNotesTooLong => 'Notes must be 2,000 characters or fewer';

  @override
  String get poiIssueDuplicate => 'Duplicate in the file or already saved';

  @override
  String get poiImportComplete => 'POI import complete';

  @override
  String get poiTotal => 'Total records';

  @override
  String get poiImported => 'Imported';

  @override
  String get poiSkipped => 'Skipped';

  @override
  String get poiShowPoints => 'Show points on the map';

  @override
  String get poiInvalidFile =>
      'Could not read the file. Use the XLSX template, up to 20 MB and 5,000 records.';

  @override
  String get poiFileSaved => 'File saved';

  @override
  String get poiFileError => 'Could not save the file. Please try again.';

  @override
  String get poiReason => 'Reason';

  @override
  String get poiInvalidRow => 'Check name, coordinates, icon and notes length';

  @override
  String get poiStatus => 'Status';
}
