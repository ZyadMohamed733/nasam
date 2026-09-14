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
  /// In ar, this message translates to:
  /// **'ناسم'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما. يرجى المحاولة مرة أخرى.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.'**
  String get errorUnauthorized;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @emptyState.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات متاحة.'**
  String get emptyState;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'{field} مطلوب.'**
  String validationRequired(String field);

  /// No description provided for @validationRequiredGeneric.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب.'**
  String get validationRequiredGeneric;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح.'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordWeak.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون كلمة المرور مكونة من 8 رموز على الأقل وتحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص.'**
  String get validationPasswordWeak;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين.'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف سعودي صحيح.'**
  String get validationInvalidPhone;

  /// No description provided for @validationMinLength.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى {min} حرفاً.'**
  String validationMinLength(int min);

  /// No description provided for @validationMaxLength.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى {max} حرفاً.'**
  String validationMaxLength(int max);

  /// No description provided for @validationNotNumeric.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون القيمة رقمية.'**
  String get validationNotNumeric;

  /// No description provided for @validationNotArabic.
  ///
  /// In ar, this message translates to:
  /// **'يُسمح بالأحرف العربية فقط.'**
  String get validationNotArabic;

  /// No description provided for @validationInvalidLatitude.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون خط العرض بين -90.0 و90.0.'**
  String get validationInvalidLatitude;

  /// No description provided for @validationInvalidLongitude.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون خط الطول بين -180.0 و180.0.'**
  String get validationInvalidLongitude;

  /// No description provided for @validationInvalidPlateNumber.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم لوحة سعودي صحيح.'**
  String get validationInvalidPlateNumber;

  /// No description provided for @relativeJustNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الآن} one{منذ دقيقة} two{منذ دقيقتين} few{منذ {count} دقائق} many{منذ {count} دقيقة} other{منذ {count} دقيقة}}'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الآن} one{منذ ساعة} two{منذ ساعتين} few{منذ {count} ساعات} many{منذ {count} ساعة} other{منذ {count} ساعة}}'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{اليوم} one{منذ يوم} two{منذ يومين} few{منذ {count} أيام} many{منذ {count} يوماً} other{منذ {count} يوم}}'**
  String relativeDaysAgo(int count);

  /// No description provided for @relativeWeeksAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{هذا الأسبوع} one{منذ أسبوع} two{منذ أسبوعين} few{منذ {count} أسابيع} many{منذ {count} أسبوعاً} other{منذ {count} أسبوع}}'**
  String relativeWeeksAgo(int count);

  /// Reference plural for new features to copy. Arabic needs six categories where English needs two.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا توجد مركبات} one{مركبة واحدة} two{مركبتان} few{{count} مركبات} many{{count} مركبة} other{{count} مركبة}}'**
  String vehicleCount(int count);

  /// Countdown beneath the OTP fields. {time} is mm:ss. DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي صلاحية الرمز خلال {time}'**
  String otpExpiresIn(String time);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الرمز.'**
  String get otpExpired;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file, which sets it as one sentence with otpResend.
  ///
  /// In ar, this message translates to:
  /// **'لم يصلك الرمز؟'**
  String get otpNotReceived;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file, which sets it as one sentence with otpNotReceived.
  ///
  /// In ar, this message translates to:
  /// **'أعد إرسال الرمز'**
  String get otpResend;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'كل مركبة على شاشة واحدة'**
  String get onboardingTitle1;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'تابع أسطولك مباشرة أينما كان على الطريق.'**
  String get onboardingBody1;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'مسارات تُخطَّط تلقائياً'**
  String get onboardingTitle2;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'اعرف أسرع طريق، واعرف لحظة تغيّره.'**
  String get onboardingBody2;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'فريقك على تناغم'**
  String get onboardingTitle3;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'شارك الخطط والتحديثات ليعمل الجميع على الصورة نفسها.'**
  String get onboardingBody3;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'تخطٍ'**
  String get onboardingSkip;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingStart;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك ادخل البيانات ل تسجيل الدخول'**
  String get loginSubtitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'البريد الالكتروني'**
  String get loginEmailLabel;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'a.hassan@tracking.sa'**
  String get loginEmailHint;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordLabel;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordHint;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginSubmit;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'هل نسيت كلمه المرور!'**
  String get loginForgotPassword;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمه المرور'**
  String get forgotPasswordTitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني المسجل وسنرسل لك تعليمات لاستعادة حسابك.'**
  String get forgotPasswordSubtitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'ارسال'**
  String get forgotPasswordSubmit;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من رمزك'**
  String get otpTitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز المرور الذي استلمته للتو على عنوان بريدك الإلكتروني الذي ينتهي بـ {email}'**
  String otpSubtitle(String email);

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'ارسال'**
  String get otpSubmit;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'كلمه مرور جديده'**
  String get newPasswordTitle;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'كلمه المرور'**
  String get newPasswordLabel;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمه المرور'**
  String get newPasswordConfirmLabel;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get newPasswordSubmit;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'تم تغير كلمة المرور بنجاح'**
  String get newPasswordDone;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يحتوي على {count} أحرف على الأقل'**
  String passwordRuleMinLength(int count);

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'حرف كبير واحد A-Z'**
  String get passwordRuleUppercase;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'حرف واحد صغير a-z'**
  String get passwordRuleLowercase;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'رقم واحد على الأقل'**
  String get passwordRuleDigit;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'رمز واحد علي الاقل @!#\$%^&*'**
  String get passwordRuleSpecialCharacter;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get loginUsernameLabel;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get loginUsernameHint;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'العوده لتسجيل الدخول'**
  String get authBackToLogin;

  /// DESIGN-VERIFIED. This Arabic is verbatim from the design file.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك ادخل البيانات ل انشاء كلمه مرور جديده'**
  String get newPasswordSubtitle;
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
