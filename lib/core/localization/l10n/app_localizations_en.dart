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
  String get otpSubtitle => 'We sent a six-digit code to your registered email address.';

  @override
  String get forgotPasswordCheckEmailTitle => 'Check your email';

  @override
  String get forgotPasswordCheckEmailSubtitle =>
      "If an account exists for that email address, we've sent a password reset link to it.";

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
  String get trackingAdmin => 'System administrator';

  @override
  String get trackingVehicle => 'Delivery van';

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
}
