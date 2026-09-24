// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ناسم';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUnauthorized =>
      'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get ok => 'موافق';

  @override
  String get emptyState => 'لا توجد بيانات متاحة.';

  @override
  String validationRequired(String field) {
    return '$field مطلوب.';
  }

  @override
  String get validationRequiredGeneric => 'هذا الحقل مطلوب.';

  @override
  String get validationInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get validationPasswordWeak =>
      'يجب أن تكون كلمة المرور مكونة من 8 رموز على الأقل وتحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص.';

  @override
  String get validationPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get validationInvalidPhone => 'يرجى إدخال رقم هاتف سعودي صحيح.';

  @override
  String validationMinLength(int min) {
    return 'الحد الأدنى $min حرفاً.';
  }

  @override
  String validationMaxLength(int max) {
    return 'الحد الأقصى $max حرفاً.';
  }

  @override
  String get validationNotNumeric => 'يجب أن تكون القيمة رقمية.';

  @override
  String get validationNotArabic => 'يُسمح بالأحرف العربية فقط.';

  @override
  String get validationInvalidLatitude =>
      'يجب أن يكون خط العرض بين -90.0 و90.0.';

  @override
  String get validationInvalidLongitude =>
      'يجب أن يكون خط الطول بين -180.0 و180.0.';

  @override
  String get validationInvalidPlateNumber => 'يرجى إدخال رقم لوحة سعودي صحيح.';

  @override
  String get relativeJustNow => 'الآن';

  @override
  String relativeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count أسبوع',
      many: 'منذ $count أسبوعاً',
      few: 'منذ $count أسابيع',
      two: 'منذ أسبوعين',
      one: 'منذ أسبوع',
      zero: 'هذا الأسبوع',
    );
    return '$_temp0';
  }

  @override
  String vehicleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مركبة',
      many: '$count مركبة',
      few: '$count مركبات',
      two: 'مركبتان',
      one: 'مركبة واحدة',
      zero: 'لا توجد مركبات',
    );
    return '$_temp0';
  }

  @override
  String otpExpiresIn(String time) {
    return 'ينتهي صلاحية الرمز خلال $time';
  }

  @override
  String get otpExpired => 'انتهت صلاحية الرمز.';

  @override
  String get otpNotReceived => 'لم يصلك الرمز؟';

  @override
  String get otpResend => 'أعد إرسال الرمز';

  @override
  String get onboardingTitle1 => 'كل مركبة على شاشة واحدة';

  @override
  String get onboardingBody1 => 'تابع أسطولك مباشرة أينما كان على الطريق.';

  @override
  String get onboardingTitle2 => 'مسارات تُخطَّط تلقائياً';

  @override
  String get onboardingBody2 => 'اعرف أسرع طريق، واعرف لحظة تغيّره.';

  @override
  String get onboardingTitle3 => 'فريقك على تناغم';

  @override
  String get onboardingBody3 =>
      'شارك الخطط والتحديثات ليعمل الجميع على الصورة نفسها.';

  @override
  String get onboardingSkip => 'تخطٍ';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'من فضلك ادخل البيانات ل تسجيل الدخول';

  @override
  String get loginEmailLabel => 'البريد الالكتروني';

  @override
  String get loginEmailHint => 'name@company.com';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginForgotPassword => 'هل نسيت كلمه المرور!';

  @override
  String get forgotPasswordTitle => 'نسيت كلمه المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني المسجل وسنرسل لك تعليمات لاستعادة حسابك.';

  @override
  String get forgotPasswordSubmit => 'ارسال';

  @override
  String get otpTitle => 'تحقق من رمزك';

  @override
  String get otpSubtitle =>
      'أرسلنا رمزًا مكونًا من ستة أرقام إلى عنوان بريدك الإلكتروني المسجل.';

  @override
  String get forgotPasswordCheckEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get forgotPasswordCheckEmailSubtitle =>
      'إذا كان هناك حساب مرتبط بهذا البريد الإلكتروني، فسنرسل إليه رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get otpSubmit => 'ارسال';

  @override
  String get newPasswordTitle => 'كلمه مرور جديده';

  @override
  String get newPasswordLabel => 'كلمه المرور';

  @override
  String get newPasswordConfirmLabel => 'تأكيد كلمه المرور';

  @override
  String get newPasswordSubmit => 'حفظ';

  @override
  String get newPasswordDone => 'تم تغير كلمة المرور بنجاح';

  @override
  String passwordRuleMinLength(int count) {
    return 'يجب أن يحتوي على $count أحرف على الأقل';
  }

  @override
  String get passwordRuleMatches => 'تطابق كلمتي المرور';

  @override
  String get passwordRuleUppercase => 'حرف كبير واحد A-Z';

  @override
  String get passwordRuleLowercase => 'حرف واحد صغير a-z';

  @override
  String get passwordRuleDigit => 'رقم واحد على الأقل';

  @override
  String get passwordRuleSpecialCharacter => 'رمز واحد علي الاقل @!#\$%^&*';

  @override
  String get loginUsernameLabel => 'اسم المستخدم';

  @override
  String get loginUsernameHint => 'اسم المستخدم';

  @override
  String get authBackToLogin => 'العوده لتسجيل الدخول';

  @override
  String get newPasswordSubtitle =>
      'من فضلك ادخل البيانات ل انشاء كلمه مرور جديده';

  @override
  String get trackingTitle => 'لوحة التتبع';

  @override
  String get trackingShow => 'عرض';

  @override
  String get trackingAll => 'الكل';

  @override
  String get trackingMoving => 'المتحرك';

  @override
  String get trackingIdle => 'متوقف مؤقتاً';

  @override
  String get trackingStopped => 'المتوقف';

  @override
  String get trackingOffline => 'غير متصل';

  @override
  String get trackingSearch => 'بحث';

  @override
  String get trackingSystems => 'الأنظمة';

  @override
  String get trackingFleet => 'الاسطول';

  @override
  String get trackingPoi => 'نقاط الاهتمام';

  @override
  String get trackingGeofences => 'مناطق جغرافية';

  @override
  String get trackingAssignments => 'إدارة التعيينات';

  @override
  String get trackingSettings => 'الإعدادات';

  @override
  String get trackingAsset => 'الأصل';

  @override
  String get trackingNotifications => 'الإشعارات';

  @override
  String get trackingLayers => 'الطبقات';

  @override
  String get trackingZoomIn => 'تكبير';

  @override
  String get trackingZoomOut => 'تصغير';

  @override
  String get trackingMenu => 'القائمة';

  @override
  String get trackingLogout => 'تسجيل الخروج';

  @override
  String get assetDetailsInformation => 'المعلومات';

  @override
  String get assetDetailsTracking => 'التتبع';

  @override
  String get assetDetailsLocation => 'الموقع';

  @override
  String get assetDetailsAssets => 'الحساسات';

  @override
  String get assetDetailsNotifications => 'التنبيهات';

  @override
  String get assetDetailsName => 'اسم الأصل';

  @override
  String get assetDetailsType => 'النوع';

  @override
  String get assetDetailsCompany => 'الشركة';

  @override
  String get assetDetailsId => 'رقم الأصل';

  @override
  String get assetDetailsAssignedPerson => 'المستخدم المسؤول';

  @override
  String get assetDetailsManager => 'المسؤول';

  @override
  String get assetDetailsSpeed => 'السرعة';

  @override
  String get assetDetailsDuration => 'المدة';

  @override
  String get assetDetailsStatus => 'حالة الأصل';

  @override
  String get assetDetailsConnection => 'آخر اتصال';

  @override
  String get assetDetailsGpsTime => 'وقت GPS';

  @override
  String get assetDetailsDistance => 'المسافة';

  @override
  String get assetDetailsFuel => 'الوقود';

  @override
  String get assetDetailsIdleTime => 'مدة التوقف';

  @override
  String get assetDetailsTankLevel => 'مستوى الوقود';

  @override
  String get assetDetailsTemperature => 'درجة الحرارة';

  @override
  String get assetDetailsWeight => 'الوزن';

  @override
  String get assetDetailsSensorHistory => 'سجل الحساس';

  @override
  String get assetDetailsDownload => 'تنزيل';

  @override
  String get assetDetailsFuelUsage => 'استهلاك الوقود';

  @override
  String get assetDetailsDoor => 'الباب';

  @override
  String get assetDetailsEngine => 'المحرك';

  @override
  String get assetDetailsAddress => 'العنوان';

  @override
  String get assetDetailsAlertName => 'اسم التنبيه';

  @override
  String get assetDetailsAlertType => 'نوع التنبيه';

  @override
  String get assetDetailsAlertSpeed => 'السرعة';

  @override
  String get assetDetailsAlertDate => 'التاريخ';

  @override
  String get assetDetailsAlertLocation => 'الموقع';

  @override
  String get assetDetailsRunning => 'يعمل';

  @override
  String get assetDetailsOpen => 'مفتوح';

  @override
  String get assetDetailsClosed => 'مغلق';

  @override
  String get assetDetailsOn => 'يعمل';

  @override
  String get assetDetailsOff => 'متوقف';

  @override
  String get assetDetailsSpeedingAlert => 'تجاوز الحد الأقصى للسرعة';

  @override
  String get assetDetailsStoppedAlert => 'توقف الأصل';

  @override
  String get assetDetailsGeofenceAlert => 'دخول النطاق الجغرافي';

  @override
  String get assetDetailsEmptyAlerts => 'لا توجد تنبيهات لهذا الأصل.';

  @override
  String get assetPlaybackTitle => 'إعادة التشغيل';

  @override
  String get assetPlaybackFrom => 'من تاريخ';

  @override
  String get assetPlaybackTo => 'إلى تاريخ';

  @override
  String get assetPlaybackStart => 'بدء التشغيل';

  @override
  String get assetPlaybackPause => 'إيقاف التشغيل مؤقتاً';

  @override
  String get assetPlaybackPlay => 'تشغيل المقطع';

  @override
  String get assetPlaybackEmpty => 'لا توجد سجلات تشغيل ضمن هذه الفترة.';

  @override
  String get assetPlaybackDistance => 'المسافة';

  @override
  String get assetPlaybackMaxSpeed => 'السرعة القصوى';

  @override
  String get assetPlaybackDuration => 'المدة';

  @override
  String get assetPlaybackKilometers => 'كم';

  @override
  String get assetPlaybackKilometersPerHour => 'كم/س';

  @override
  String get assetPlaybackMinutes => 'دقيقة';

  @override
  String get assetNotFound => 'لم يتم العثور على هذا الأصل.';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get sessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get trackingNoMatches => 'لا توجد أصول مطابقة لبحثك.';

  @override
  String get trackingClearFilters => 'مسح عوامل التصفية';

  @override
  String get trackingCollapse => 'طي القائمة';

  @override
  String trackingStatusChip(String status, int count) {
    return '$status: $count';
  }

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get trackingActionCamera => 'الكاميرا المباشرة';

  @override
  String get trackingActionChat => 'مراسلة';

  @override
  String get trackingActionLocate => 'إظهار على الخريطة';

  @override
  String get trackingActionCall => 'اتصال';

  @override
  String get trackingActionEmail => 'بريد إلكتروني';

  @override
  String unitSpeedKph(String value) {
    return '$value كم/س';
  }

  @override
  String unitDistanceKm(String value) {
    return '$value كم';
  }

  @override
  String unitWeightKg(String value) {
    return '$value كجم';
  }

  @override
  String unitHours(String value) {
    return '$value س';
  }

  @override
  String unitCelsius(String value) {
    return '$value °م';
  }

  @override
  String unitPercent(String value) {
    return '$value٪';
  }

  @override
  String durationMinutesSeconds(String minutes, String seconds) {
    return '$minutes م $seconds ث';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours س $minutes م';
  }

  @override
  String get userTypeAdmin => 'مدير النظام';

  @override
  String get userTypeEmployee => 'موظف';

  @override
  String get userTypeClientAdmin => 'مدير العميل';

  @override
  String get userTypeClientEmployee => 'موظف العميل';

  @override
  String unitMillivolts(String value) {
    return '$value مللي فولت';
  }
}
