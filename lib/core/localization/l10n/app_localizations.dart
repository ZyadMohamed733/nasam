import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nasam'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get emptyState;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required.'**
  String validationRequired(String field);

  /// No description provided for @validationRequiredGeneric.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequiredGeneric;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with uppercase, lowercase, number and symbol.'**
  String get validationPasswordWeak;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Saudi phone number.'**
  String get validationInvalidPhone;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum length is {min} characters.'**
  String validationMinLength(int min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum length is {max} characters.'**
  String validationMaxLength(int max);

  /// No description provided for @validationNotNumeric.
  ///
  /// In en, this message translates to:
  /// **'Value must be numeric.'**
  String get validationNotNumeric;

  /// No description provided for @validationNotArabic.
  ///
  /// In en, this message translates to:
  /// **'Only Arabic characters are allowed.'**
  String get validationNotArabic;

  /// No description provided for @validationInvalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90.0 and 90.0.'**
  String get validationInvalidLatitude;

  /// No description provided for @validationInvalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180.0 and 180.0.'**
  String get validationInvalidLongitude;

  /// No description provided for @validationInvalidPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Saudi plate number.'**
  String get validationInvalidPlateNumber;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 minute ago} other{{count} minutes ago}}'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day ago} other{{count} days ago}}'**
  String relativeDaysAgo(int count);

  /// No description provided for @relativeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 week ago} other{{count} weeks ago}}'**
  String relativeWeeksAgo(int count);

  /// Reference plural for new features to copy. Arabic needs six categories where English needs two.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No vehicles} one{1 vehicle} other{{count} vehicles}}'**
  String vehicleCount(int count);

  /// Countdown beneath the OTP fields. {time} is mm:ss.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {time}'**
  String otpExpiresIn(String time);

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired.'**
  String get otpExpired;

  /// No description provided for @otpNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpNotReceived;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// Screen-reader label for a single OTP box.
  ///
  /// In en, this message translates to:
  /// **'Digit {position} of {count}'**
  String otpFieldLabel(int position, int count);

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Every vehicle, on one screen'**
  String get onboardingTitle1;

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Follow your whole fleet live, wherever it is on the road.'**
  String get onboardingBody1;

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Routes that plan themselves'**
  String get onboardingTitle2;

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'See the fastest way through, and know the moment it changes.'**
  String get onboardingBody2;

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Your team, in step'**
  String get onboardingTitle3;

  /// PLACEHOLDER COPY — not from the design file, which supplies the artwork but no text for this slide. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Share plans and updates so everyone is working from the same picture.'**
  String get onboardingBody3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow your fleet.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get loginPasswordHint;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgotPassword;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordSubmit;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit code to {email}.'**
  String otpSubtitle(String email);

  /// No description provided for @otpSubmit.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpSubmit;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get newPasswordConfirmLabel;

  /// No description provided for @newPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get newPasswordSubmit;

  /// PLACEHOLDER COPY — the design file was not available for this string. Replace with the approved wording.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed. Sign in to continue.'**
  String get newPasswordDone;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordRuleMinLength(int count);

  /// No description provided for @passwordRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get passwordRuleUppercase;

  /// No description provided for @passwordRuleLowercase.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get passwordRuleLowercase;

  /// No description provided for @passwordRuleDigit.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get passwordRuleDigit;

  /// No description provided for @passwordRuleSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get passwordRuleSpecialCharacter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
