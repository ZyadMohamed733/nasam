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
  /// **'name@company.com'**
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

  /// NOT design-verified -- this is the OTP screen's own copy, now that it is reached from login (a username) rather than forgot-password (an email the app had just been given). It no longer quotes an address, since the app is not told which one the code went to. Needs a design/localization pass before shipping.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا مكونًا من ستة أرقام إلى عنوان بريدك الإلكتروني المسجل.'**
  String get otpSubtitle;

  /// NOT design-verified -- inline confirmation shown on ForgotPasswordPage after forget-password succeeds (per the web-only reset decision in docs/plans/AUTH_INTEGRATION_PLAN.md). Needs a design/localization pass before shipping.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني'**
  String get forgotPasswordCheckEmailTitle;

  /// NOT design-verified. Deliberately non-committal about whether the address exists, matching the API's own message (POST /auth/forget-password never signals existence either way). Needs a design/localization pass before shipping.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان هناك حساب مرتبط بهذا البريد الإلكتروني، فسنرسل إليه رابطًا لإعادة تعيين كلمة المرور.'**
  String get forgotPasswordCheckEmailSubtitle;

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

  /// No description provided for @passwordRuleMatches.
  ///
  /// In ar, this message translates to:
  /// **'تطابق كلمتي المرور'**
  String get passwordRuleMatches;

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

  /// No description provided for @trackingTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التتبع'**
  String get trackingTitle;

  /// No description provided for @trackingShow.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get trackingShow;

  /// No description provided for @trackingAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get trackingAll;

  /// No description provided for @trackingMoving.
  ///
  /// In ar, this message translates to:
  /// **'المتحرك'**
  String get trackingMoving;

  /// No description provided for @trackingIdle.
  ///
  /// In ar, this message translates to:
  /// **'متوقف مؤقتاً'**
  String get trackingIdle;

  /// No description provided for @trackingStopped.
  ///
  /// In ar, this message translates to:
  /// **'المتوقف'**
  String get trackingStopped;

  /// No description provided for @trackingOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get trackingOffline;

  /// No description provided for @trackingSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get trackingSearch;

  /// No description provided for @trackingSystems.
  ///
  /// In ar, this message translates to:
  /// **'الأنظمة'**
  String get trackingSystems;

  /// No description provided for @trackingFleet.
  ///
  /// In ar, this message translates to:
  /// **'الاسطول'**
  String get trackingFleet;

  /// No description provided for @trackingPoi.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الاهتمام'**
  String get trackingPoi;

  /// No description provided for @trackingGeofences.
  ///
  /// In ar, this message translates to:
  /// **'مناطق جغرافية'**
  String get trackingGeofences;

  /// No description provided for @trackingAssignments.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التعيينات'**
  String get trackingAssignments;

  /// No description provided for @trackingSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get trackingSettings;

  /// No description provided for @trackingAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get trackingAdmin;

  /// No description provided for @trackingAsset.
  ///
  /// In ar, this message translates to:
  /// **'الأصل'**
  String get trackingAsset;

  /// No description provided for @trackingNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get trackingNotifications;

  /// No description provided for @trackingLayers.
  ///
  /// In ar, this message translates to:
  /// **'الطبقات'**
  String get trackingLayers;

  /// No description provided for @trackingZoomIn.
  ///
  /// In ar, this message translates to:
  /// **'تكبير'**
  String get trackingZoomIn;

  /// No description provided for @trackingZoomOut.
  ///
  /// In ar, this message translates to:
  /// **'تصغير'**
  String get trackingZoomOut;

  /// No description provided for @trackingMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get trackingMenu;

  /// No description provided for @trackingLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get trackingLogout;

  /// No description provided for @drawerDemoProfileName.
  ///
  /// In ar, this message translates to:
  /// **'Aya Al-Rashidi'**
  String get drawerDemoProfileName;

  /// No description provided for @assetDetailsInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات'**
  String get assetDetailsInformation;

  /// No description provided for @assetDetailsTracking.
  ///
  /// In ar, this message translates to:
  /// **'التتبع'**
  String get assetDetailsTracking;

  /// No description provided for @assetDetailsLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get assetDetailsLocation;

  /// No description provided for @assetDetailsAssets.
  ///
  /// In ar, this message translates to:
  /// **'الحساسات'**
  String get assetDetailsAssets;

  /// No description provided for @assetDetailsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get assetDetailsNotifications;

  /// No description provided for @assetDetailsName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الأصل'**
  String get assetDetailsName;

  /// No description provided for @assetDetailsType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get assetDetailsType;

  /// No description provided for @assetDetailsCompany.
  ///
  /// In ar, this message translates to:
  /// **'الشركة'**
  String get assetDetailsCompany;

  /// No description provided for @assetDetailsId.
  ///
  /// In ar, this message translates to:
  /// **'رقم الأصل'**
  String get assetDetailsId;

  /// No description provided for @assetDetailsAssignedPerson.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم المسؤول'**
  String get assetDetailsAssignedPerson;

  /// No description provided for @assetDetailsManager.
  ///
  /// In ar, this message translates to:
  /// **'المسؤول'**
  String get assetDetailsManager;

  /// No description provided for @assetDetailsSpeed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة'**
  String get assetDetailsSpeed;

  /// No description provided for @assetDetailsDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get assetDetailsDuration;

  /// No description provided for @assetDetailsStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الأصل'**
  String get assetDetailsStatus;

  /// No description provided for @assetDetailsConnection.
  ///
  /// In ar, this message translates to:
  /// **'آخر اتصال'**
  String get assetDetailsConnection;

  /// No description provided for @assetDetailsGpsTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت GPS'**
  String get assetDetailsGpsTime;

  /// No description provided for @assetDetailsDistance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get assetDetailsDistance;

  /// No description provided for @assetDetailsFuel.
  ///
  /// In ar, this message translates to:
  /// **'الوقود'**
  String get assetDetailsFuel;

  /// No description provided for @assetDetailsIdleTime.
  ///
  /// In ar, this message translates to:
  /// **'مدة التوقف'**
  String get assetDetailsIdleTime;

  /// No description provided for @assetDetailsTankLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الوقود'**
  String get assetDetailsTankLevel;

  /// No description provided for @assetDetailsTemperature.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة'**
  String get assetDetailsTemperature;

  /// No description provided for @assetDetailsWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get assetDetailsWeight;

  /// No description provided for @assetDetailsSensorHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحساس'**
  String get assetDetailsSensorHistory;

  /// No description provided for @assetDetailsDownload.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get assetDetailsDownload;

  /// No description provided for @assetDetailsFuelUsage.
  ///
  /// In ar, this message translates to:
  /// **'استهلاك الوقود'**
  String get assetDetailsFuelUsage;

  /// No description provided for @assetDetailsDoor.
  ///
  /// In ar, this message translates to:
  /// **'الباب'**
  String get assetDetailsDoor;

  /// No description provided for @assetDetailsEngine.
  ///
  /// In ar, this message translates to:
  /// **'المحرك'**
  String get assetDetailsEngine;

  /// No description provided for @assetDetailsAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get assetDetailsAddress;

  /// No description provided for @assetDetailsAlertName.
  ///
  /// In ar, this message translates to:
  /// **'اسم التنبيه'**
  String get assetDetailsAlertName;

  /// No description provided for @assetDetailsAlertType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التنبيه'**
  String get assetDetailsAlertType;

  /// No description provided for @assetDetailsAlertSpeed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة'**
  String get assetDetailsAlertSpeed;

  /// No description provided for @assetDetailsAlertDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get assetDetailsAlertDate;

  /// No description provided for @assetDetailsAlertLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get assetDetailsAlertLocation;

  /// No description provided for @assetDetailsRunning.
  ///
  /// In ar, this message translates to:
  /// **'يعمل'**
  String get assetDetailsRunning;

  /// No description provided for @assetDetailsOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get assetDetailsOpen;

  /// No description provided for @assetDetailsClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get assetDetailsClosed;

  /// No description provided for @assetDetailsOn.
  ///
  /// In ar, this message translates to:
  /// **'يعمل'**
  String get assetDetailsOn;

  /// No description provided for @assetDetailsOff.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get assetDetailsOff;

  /// No description provided for @assetDetailsSpeedingAlert.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز الحد الأقصى للسرعة'**
  String get assetDetailsSpeedingAlert;

  /// No description provided for @assetDetailsStoppedAlert.
  ///
  /// In ar, this message translates to:
  /// **'توقف الأصل'**
  String get assetDetailsStoppedAlert;

  /// No description provided for @assetDetailsGeofenceAlert.
  ///
  /// In ar, this message translates to:
  /// **'دخول النطاق الجغرافي'**
  String get assetDetailsGeofenceAlert;

  /// No description provided for @assetDetailsEmptyAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات لهذا الأصل.'**
  String get assetDetailsEmptyAlerts;

  /// No description provided for @assetPlaybackTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التشغيل'**
  String get assetPlaybackTitle;

  /// No description provided for @assetPlaybackFrom.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get assetPlaybackFrom;

  /// No description provided for @assetPlaybackTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get assetPlaybackTo;

  /// No description provided for @assetPlaybackStart.
  ///
  /// In ar, this message translates to:
  /// **'بدء التشغيل'**
  String get assetPlaybackStart;

  /// No description provided for @assetPlaybackPause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف التشغيل مؤقتاً'**
  String get assetPlaybackPause;

  /// No description provided for @assetPlaybackPlay.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل المقطع'**
  String get assetPlaybackPlay;

  /// No description provided for @assetPlaybackEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات تشغيل ضمن هذه الفترة.'**
  String get assetPlaybackEmpty;

  /// No description provided for @assetPlaybackDistance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get assetPlaybackDistance;

  /// No description provided for @assetPlaybackMaxSpeed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة القصوى'**
  String get assetPlaybackMaxSpeed;

  /// No description provided for @assetPlaybackDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get assetPlaybackDuration;

  /// No description provided for @assetPlaybackKilometers.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get assetPlaybackKilometers;

  /// No description provided for @assetPlaybackKilometersPerHour.
  ///
  /// In ar, this message translates to:
  /// **'كم/س'**
  String get assetPlaybackKilometersPerHour;

  /// No description provided for @assetPlaybackMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get assetPlaybackMinutes;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على هذا الأصل.'**
  String get assetNotFound;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get backToHome;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording. Shown once on the login screen when the server ended the session.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.'**
  String get sessionExpired;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصول مطابقة لبحثك.'**
  String get trackingNoMatches;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'مسح عوامل التصفية'**
  String get trackingClearFilters;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'طي القائمة'**
  String get trackingCollapse;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{status}: {count}'**
  String trackingStatusChip(String status, int count);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get comingSoon;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا المباشرة'**
  String get trackingActionCamera;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة'**
  String get trackingActionChat;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'إظهار على الخريطة'**
  String get trackingActionLocate;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get trackingActionCall;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني'**
  String get trackingActionEmail;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} كم/س'**
  String unitSpeedKph(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} كم'**
  String unitDistanceKm(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} كجم'**
  String unitWeightKg(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} س'**
  String unitHours(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} °م'**
  String unitCelsius(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value}٪'**
  String unitPercent(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording. Form taken from the design's card ('٠٧ م ٠٩ ث').
  ///
  /// In ar, this message translates to:
  /// **'{minutes} م {seconds} ث'**
  String durationMinutesSeconds(String minutes, String seconds);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{hours} س {minutes} م'**
  String durationHoursMinutes(String hours, String minutes);
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
