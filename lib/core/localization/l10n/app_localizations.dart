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

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @playbackTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get playbackTime;

  /// No description provided for @morning.
  ///
  /// In ar, this message translates to:
  /// **'صباحا'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In ar, this message translates to:
  /// **'مساء'**
  String get evening;

  /// No description provided for @hour.
  ///
  /// In ar, this message translates to:
  /// **'الساعة'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In ar, this message translates to:
  /// **'الدقيقة'**
  String get minute;

  /// No description provided for @playbackChooseDay.
  ///
  /// In ar, this message translates to:
  /// **'اختار اليوم'**
  String get playbackChooseDay;

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

  /// No description provided for @trackingSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get trackingSettings;

  /// No description provided for @trackingAsset.
  ///
  /// In ar, this message translates to:
  /// **'الأصل'**
  String get trackingAsset;

  /// No description provided for @trackingLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث · منذ ٢ د'**
  String get trackingLastUpdated;

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

  /// No description provided for @assetDetailsInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
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

  /// No description provided for @manageAlerts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التنبيهات'**
  String get manageAlerts;

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

  /// No description provided for @alertAsset.
  ///
  /// In ar, this message translates to:
  /// **'الأصل'**
  String get alertAsset;

  /// No description provided for @alertType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get alertType;

  /// No description provided for @alertValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get alertValue;

  /// No description provided for @alertTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get alertTime;

  /// No description provided for @alertLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get alertLocation;

  /// No description provided for @alertDetailsSpeedInfo.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السرعة'**
  String get alertDetailsSpeedInfo;

  /// No description provided for @alertDetailsRecordedSpeed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة المسجلة'**
  String get alertDetailsRecordedSpeed;

  /// No description provided for @alertDetailsSpeedLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للسرعة'**
  String get alertDetailsSpeedLimit;

  /// No description provided for @alertDetailsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التنبيه'**
  String get alertDetailsSubtitle;

  /// No description provided for @alertFilter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get alertFilter;

  /// No description provided for @alertsNoSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على تنبيهات وفقًا للمعايير المحددة. حاول تعديل البحث أو عوامل التصفية.'**
  String get alertsNoSearchResults;

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

  /// No description provided for @alertsLogUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل تنبيهات متاح'**
  String get alertsLogUnavailable;

  /// No description provided for @deviceAlertsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات لهذا الجهاز حاليا'**
  String get deviceAlertsEmpty;

  /// No description provided for @assetPlaybackTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التشغيل'**
  String get assetPlaybackTitle;

  /// AWAITING DESIGN COPY
  ///
  /// In ar, this message translates to:
  /// **'الموقع السابق'**
  String get playbackPrevious;

  /// AWAITING DESIGN COPY
  ///
  /// In ar, this message translates to:
  /// **'الموقع التالي'**
  String get playbackNext;

  /// AWAITING DESIGN COPY
  ///
  /// In ar, this message translates to:
  /// **'معلومات المسار'**
  String get playbackInfo;

  /// No description provided for @playbackInfoAssetInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الأصل'**
  String get playbackInfoAssetInformation;

  /// No description provided for @playbackInfoDate.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get playbackInfoDate;

  /// No description provided for @playbackInfoStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get playbackInfoStatus;

  /// No description provided for @playbackInfoIgnition.
  ///
  /// In ar, this message translates to:
  /// **'الإشعال'**
  String get playbackInfoIgnition;

  /// No description provided for @playbackInfoOdometer.
  ///
  /// In ar, this message translates to:
  /// **'عداد المسافة'**
  String get playbackInfoOdometer;

  /// No description provided for @playbackInfoLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get playbackInfoLocation;

  /// No description provided for @playbackInfoSensors.
  ///
  /// In ar, this message translates to:
  /// **'الحساسات'**
  String get playbackInfoSensors;

  /// No description provided for @playbackInfoFuelLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الوقود'**
  String get playbackInfoFuelLevel;

  /// No description provided for @playbackInfoHumidity.
  ///
  /// In ar, this message translates to:
  /// **'الرطوبة'**
  String get playbackInfoHumidity;

  /// No description provided for @playbackInfoMoving.
  ///
  /// In ar, this message translates to:
  /// **'متحرك'**
  String get playbackInfoMoving;

  /// No description provided for @playbackInfoIgnitionOn.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get playbackInfoIgnitionOn;

  /// No description provided for @playbackInfoIgnitionOff.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get playbackInfoIgnitionOff;

  /// AWAITING DESIGN COPY
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get playbackBack;

  /// No description provided for @assetPlaybackFrom.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get assetPlaybackFrom;

  /// No description provided for @assetPlaybackTo.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النهاية'**
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

  /// Design copy: the drawer reference labels an administrator this way.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get userTypeAdmin;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get userTypeEmployee;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'مدير العميل'**
  String get userTypeClientAdmin;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'موظف العميل'**
  String get userTypeClientEmployee;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'{value} مللي فولت'**
  String unitMillivolts(String value);

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد.'**
  String get resetCodeResent;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'طلب رمز جديد'**
  String get resetStartOver;

  /// Design copy: the drawer reference labels the alerts log this way.
  ///
  /// In ar, this message translates to:
  /// **'سجل التنبيهات'**
  String get drawerAlertsLog;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get drawerNoResults;

  /// AWAITING DESIGN COPY. Arabic here is a back-translation of invented English, not design copy. Do not treat it as approved wording.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get drawerClearSearch;

  /// No description provided for @poiAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نقاط اهتمام'**
  String get poiAdd;

  /// No description provided for @poiUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get poiUpload;

  /// No description provided for @poiDownload.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get poiDownload;

  /// No description provided for @poiNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نقاط اهتمام مطابقة للبحث'**
  String get poiNoResults;

  /// No description provided for @poiEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نقاط اهتمام حتى الآن'**
  String get poiEmpty;

  /// No description provided for @poiHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get poiHide;

  /// No description provided for @poiLatitude.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض'**
  String get poiLatitude;

  /// No description provided for @poiLongitude.
  ///
  /// In ar, this message translates to:
  /// **'خط الطول'**
  String get poiLongitude;

  /// No description provided for @poiDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل نقاط الاهتمام'**
  String get poiDetails;

  /// No description provided for @poiShowOnMap.
  ///
  /// In ar, this message translates to:
  /// **'عرض على الخريطة'**
  String get poiShowOnMap;

  /// No description provided for @poiActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات'**
  String get poiActions;

  /// No description provided for @poiEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get poiEdit;

  /// No description provided for @poiDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get poiDelete;

  /// No description provided for @poiCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نقطة اهتمام جديدة'**
  String get poiCreateTitle;

  /// No description provided for @poiSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تفاصيل النقطة'**
  String get poiSubtitle;

  /// No description provided for @poiBasicInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
  String get poiBasicInfo;

  /// No description provided for @poiName.
  ///
  /// In ar, this message translates to:
  /// **'اسم نقطة الاهتمام'**
  String get poiName;

  /// No description provided for @poiLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get poiLocation;

  /// No description provided for @poiIcon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get poiIcon;

  /// No description provided for @poiLatitudeField.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض (Latitude)'**
  String get poiLatitudeField;

  /// No description provided for @poiLongitudeField.
  ///
  /// In ar, this message translates to:
  /// **'خط الطول (Longitude)'**
  String get poiLongitudeField;

  /// No description provided for @poiSelectedCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'إحداثيات الموقع المحدد'**
  String get poiSelectedCoordinates;

  /// No description provided for @poiNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال : poi'**
  String get poiNameHint;

  /// No description provided for @poiIconHint.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الأيقونة'**
  String get poiIconHint;

  /// No description provided for @poiIconLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع'**
  String get poiIconLocation;

  /// No description provided for @poiNotes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get poiNotes;

  /// No description provided for @poiFuel.
  ///
  /// In ar, this message translates to:
  /// **'محطة وقود'**
  String get poiFuel;

  /// No description provided for @poiHospital.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى'**
  String get poiHospital;

  /// No description provided for @poiLibrary.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة'**
  String get poiLibrary;

  /// No description provided for @poiCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نقطة اهتمام'**
  String get poiCreate;

  /// No description provided for @poiSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get poiSave;

  /// No description provided for @poiCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get poiCancel;

  /// No description provided for @poiRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get poiRequired;

  /// No description provided for @poiInvalidCoordinate.
  ///
  /// In ar, this message translates to:
  /// **'أدخل إحداثيات صحيحة'**
  String get poiInvalidCoordinate;

  /// No description provided for @poiNameLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى ٢٠٠ حرف'**
  String get poiNameLimit;

  /// No description provided for @poiNotesLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى ٢٠٠٠ حرف'**
  String get poiNotesLimit;

  /// No description provided for @poiSelectLocation.
  ///
  /// In ar, this message translates to:
  /// **'حدد الموقع على الخريطة'**
  String get poiSelectLocation;

  /// No description provided for @poiConfirmLocation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموقع'**
  String get poiConfirmLocation;

  /// No description provided for @poiDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف نقطة الاهتمام'**
  String get poiDeleteTitle;

  /// No description provided for @poiDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف نقطة الاهتمام؟'**
  String get poiDeleteMessage;

  /// No description provided for @poiNotFound.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الاهتمام غير موجودة'**
  String get poiNotFound;

  /// No description provided for @poiDiscardTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get poiDiscardTitle;

  /// No description provided for @poiDiscardMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم حفظ التغييرات. هل تريد المغادرة؟'**
  String get poiDiscardMessage;

  /// No description provided for @poiDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get poiDiscard;

  /// No description provided for @poiImportTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفع نقاط الاهتمام بالجملة'**
  String get poiImportTitle;

  /// No description provided for @poiImportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم برفع نقاط اهتمام متعددة باستخدام قالب الإكسل'**
  String get poiImportSubtitle;

  /// No description provided for @poiUploadStep.
  ///
  /// In ar, this message translates to:
  /// **'رفع الملف'**
  String get poiUploadStep;

  /// No description provided for @poiValidate.
  ///
  /// In ar, this message translates to:
  /// **'التحقق'**
  String get poiValidate;

  /// No description provided for @poiPreview.
  ///
  /// In ar, this message translates to:
  /// **'المعاينة'**
  String get poiPreview;

  /// No description provided for @poiConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get poiConfirm;

  /// No description provided for @poiTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل القالب'**
  String get poiTemplate;

  /// No description provided for @poiBrowse.
  ///
  /// In ar, this message translates to:
  /// **'استعراض الملفات'**
  String get poiBrowse;

  /// No description provided for @poiFileHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملف إكسل للاستيراد'**
  String get poiFileHint;

  /// No description provided for @poiFileLimits.
  ///
  /// In ar, this message translates to:
  /// **'الصيغة المدعومة: .xlsx\nالحد الأقصى لحجم الملف: 20MB\nالحد الأقصى للسجلات: 5000'**
  String get poiFileLimits;

  /// No description provided for @poiValidationTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتائج التحقق'**
  String get poiValidationTitle;

  /// No description provided for @poiPreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة نقاط الاهتمام'**
  String get poiPreviewTitle;

  /// No description provided for @poiValid.
  ///
  /// In ar, this message translates to:
  /// **'صحيح'**
  String get poiValid;

  /// No description provided for @poiInvalid.
  ///
  /// In ar, this message translates to:
  /// **'غير صحيح'**
  String get poiInvalid;

  /// No description provided for @poiDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'مكرر'**
  String get poiDuplicate;

  /// No description provided for @poiAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get poiAll;

  /// No description provided for @poiPrevious.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get poiPrevious;

  /// No description provided for @poiValidOnly.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استيراد السجلات الصحيحة فقط. لن يتم إنشاء السجلات غير الصحيحة أو المكررة.'**
  String get poiValidOnly;

  /// No description provided for @poiDropTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسحب الملفات هنا أو انقر للاستعراض'**
  String get poiDropTitle;

  /// No description provided for @poiDropHint.
  ///
  /// In ar, this message translates to:
  /// **'{format} بحد أقصى {size} ميجابايت'**
  String poiDropHint(String format, int size);

  /// No description provided for @poiFormatLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصيغة المدعومة:'**
  String get poiFormatLabel;

  /// No description provided for @poiMaxSizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى لحجم الملف:'**
  String get poiMaxSizeLabel;

  /// No description provided for @poiMaxRecordsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للسجلات:'**
  String get poiMaxRecordsLabel;

  /// No description provided for @poiSizeMegabytes.
  ///
  /// In ar, this message translates to:
  /// **'{size}MB'**
  String poiSizeMegabytes(int size);

  /// No description provided for @poiRemoveFile.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الملف'**
  String get poiRemoveFile;

  /// No description provided for @poiValidationDescription.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة نتائج التحقق لكل سجل في الملف {fileName}'**
  String poiValidationDescription(String fileName);

  /// No description provided for @poiValidationSummary.
  ///
  /// In ar, this message translates to:
  /// **'{valid} سجلاً صحيحاً جاهز للاستيراد. {invalid} سجلات تحتوي على أخطاء ولن يتم استيرادها.'**
  String poiValidationSummary(int valid, int invalid);

  /// No description provided for @poiPreviewDescription.
  ///
  /// In ar, this message translates to:
  /// **'راجع نقاط الاهتمام الصحيحة قبل استيرادها.'**
  String get poiPreviewDescription;

  /// No description provided for @poiTotalRecords.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي {count} poi'**
  String poiTotalRecords(int count);

  /// No description provided for @poiImportDoneDescription.
  ///
  /// In ar, this message translates to:
  /// **'قم برفع نقاط اهتمام متعددة باستخدام قالب الإكسل المحدد مسبقًا'**
  String get poiImportDoneDescription;

  /// No description provided for @poiImportSucceeded.
  ///
  /// In ar, this message translates to:
  /// **'تم تنزيل بنجاح'**
  String get poiImportSucceeded;

  /// No description provided for @poiImportFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت'**
  String get poiImportFailed;

  /// No description provided for @poiImportDuplicates.
  ///
  /// In ar, this message translates to:
  /// **'مكررة'**
  String get poiImportDuplicates;

  /// No description provided for @poiIssueNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get poiIssueNameRequired;

  /// No description provided for @poiIssueNameTooLong.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يتجاوز الاسم 200 حرف'**
  String get poiIssueNameTooLong;

  /// No description provided for @poiIssueLatitude.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون خط العرض بين -90 و90'**
  String get poiIssueLatitude;

  /// No description provided for @poiIssueLongitude.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون خط الطول بين -180 و180'**
  String get poiIssueLongitude;

  /// No description provided for @poiIssueIcon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة غير معروفة'**
  String get poiIssueIcon;

  /// No description provided for @poiIssueNotesTooLong.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا تتجاوز الملاحظات 2000 حرف'**
  String get poiIssueNotesTooLong;

  /// No description provided for @poiIssueDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'مكرر في الملف أو موجود مسبقاً'**
  String get poiIssueDuplicate;

  /// No description provided for @poiImportComplete.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل استيراد نقاط الاهتمام'**
  String get poiImportComplete;

  /// No description provided for @poiTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السجلات'**
  String get poiTotal;

  /// No description provided for @poiImported.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستيراد'**
  String get poiImported;

  /// No description provided for @poiSkipped.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الاستيراد'**
  String get poiSkipped;

  /// No description provided for @poiShowPoints.
  ///
  /// In ar, this message translates to:
  /// **'عرض النقاط على الخريطة'**
  String get poiShowPoints;

  /// No description provided for @poiInvalidFile.
  ///
  /// In ar, this message translates to:
  /// **'تعذر قراءة الملف. استخدم قالب XLSX، بحد أقصى 20MB و5000 سجل.'**
  String get poiInvalidFile;

  /// No description provided for @poiFileSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الملف'**
  String get poiFileSaved;

  /// No description provided for @poiFileError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ الملف. حاول مرة أخرى.'**
  String get poiFileError;

  /// No description provided for @poiReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get poiReason;

  /// No description provided for @poiInvalidRow.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من الاسم والإحداثيات والأيقونة وطول الملاحظات'**
  String get poiInvalidRow;

  /// No description provided for @poiStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get poiStatus;
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
