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
  String get validationInvalidEmail => 'Please enter a valid email address.';

  @override
  String get validationPasswordWeak =>
      'Password must be at least 8 characters with uppercase, lowercase, number and symbol.';

  @override
  String get validationInvalidPhone =>
      'Please enter a valid Saudi phone number.';
}
