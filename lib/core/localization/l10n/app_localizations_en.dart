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
}
