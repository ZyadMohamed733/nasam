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
  String get save => 'حفظ';

  @override
  String get playbackTime => 'الوقت';

  @override
  String get morning => 'صباحا';

  @override
  String get evening => 'مساء';

  @override
  String get hour => 'الساعة';

  @override
  String get minute => 'الدقيقة';

  @override
  String get playbackChooseDay => 'اختار اليوم';

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
  String get assetDetailsInformation => 'المعلومات الأساسية';

  @override
  String get assetDetailsTracking => 'التتبع';

  @override
  String get assetDetailsLocation => 'الموقع';

  @override
  String get assetDetailsAssets => 'الحساسات';

  @override
  String get assetDetailsNotifications => 'التنبيهات';

  @override
  String get manageAlerts => 'إدارة التنبيهات';

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
  String get alertAsset => 'الأصل';

  @override
  String get alertType => 'النوع';

  @override
  String get alertValue => 'القيمة';

  @override
  String get alertTime => 'الوقت';

  @override
  String get alertLocation => 'الموقع';

  @override
  String get alertDetailsSpeedInfo => 'تفاصيل السرعة';

  @override
  String get alertDetailsRecordedSpeed => 'السرعة المسجلة';

  @override
  String get alertDetailsSpeedLimit => 'الحد الأقصى للسرعة';

  @override
  String get alertDetailsSubtitle => 'تفاصيل التنبيه';

  @override
  String get alertFilter => 'تصفية';

  @override
  String get alertsNoSearchResults =>
      'لم يتم العثور على تنبيهات وفقًا للمعايير المحددة. حاول تعديل البحث أو عوامل التصفية.';

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
  String get alertsLogUnavailable => 'لا يوجد سجل تنبيهات متاح';

  @override
  String get deviceAlertsEmpty => 'لا توجد تنبيهات لهذا الجهاز حاليا';

  @override
  String get assetPlaybackTitle => 'إعادة التشغيل';

  @override
  String get playbackPrevious => 'الموقع السابق';

  @override
  String get playbackNext => 'الموقع التالي';

  @override
  String get playbackInfo => 'معلومات المسار';

  @override
  String get playbackInfoAssetInformation => 'معلومات الأصل';

  @override
  String get playbackInfoDate => 'اليوم';

  @override
  String get playbackInfoStatus => 'الحالة';

  @override
  String get playbackInfoIgnition => 'الإشعال';

  @override
  String get playbackInfoOdometer => 'عداد المسافة';

  @override
  String get playbackInfoLocation => 'الموقع';

  @override
  String get playbackInfoSensors => 'الحساسات';

  @override
  String get playbackInfoFuelLevel => 'مستوى الوقود';

  @override
  String get playbackInfoHumidity => 'الرطوبة';

  @override
  String get playbackInfoMoving => 'متحرك';

  @override
  String get playbackInfoIgnitionOn => 'تشغيل';

  @override
  String get playbackInfoIgnitionOff => 'إيقاف';

  @override
  String get playbackBack => 'رجوع';

  @override
  String get assetPlaybackFrom => 'تاريخ البداية';

  @override
  String get assetPlaybackTo => 'تاريخ النهاية';

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

  @override
  String get resetCodeResent => 'تم إرسال رمز جديد.';

  @override
  String get resetStartOver => 'طلب رمز جديد';

  @override
  String get drawerAlertsLog => 'سجل التنبيهات';

  @override
  String get drawerNoResults => 'لا توجد نتائج مطابقة';

  @override
  String get drawerClearSearch => 'مسح البحث';

  @override
  String get poiAdd => 'إضافة نقاط اهتمام';

  @override
  String get poiUpload => 'رفع';

  @override
  String get poiDownload => 'تنزيل';

  @override
  String get poiNoResults => 'لا توجد نقاط اهتمام مطابقة للبحث';

  @override
  String get poiEmpty => 'لا توجد نقاط اهتمام حتى الآن';

  @override
  String get poiHide => 'إخفاء';

  @override
  String get poiLatitude => 'خط العرض';

  @override
  String get poiLongitude => 'خط الطول';

  @override
  String get poiDetails => 'تفاصيل نقاط الاهتمام';

  @override
  String get poiShowOnMap => 'عرض على الخريطة';

  @override
  String get poiActions => 'إجراءات';

  @override
  String get poiEdit => 'تعديل';

  @override
  String get poiDelete => 'حذف';

  @override
  String get poiCreateTitle => 'إنشاء نقطة اهتمام جديدة';

  @override
  String get poiSubtitle => 'أدخل تفاصيل النقطة';

  @override
  String get poiBasicInfo => 'المعلومات الأساسية';

  @override
  String get poiName => 'اسم نقطة الاهتمام';

  @override
  String get poiLocation => 'الموقع';

  @override
  String get poiIcon => 'الأيقونة';

  @override
  String get poiLatitudeField => 'خط العرض (Latitude)';

  @override
  String get poiLongitudeField => 'خط الطول (Longitude)';

  @override
  String get poiSelectedCoordinates => 'إحداثيات الموقع المحدد';

  @override
  String get poiNameHint => 'مثال : poi';

  @override
  String get poiIconHint => 'اختيار الأيقونة';

  @override
  String get poiIconLocation => 'موقع';

  @override
  String get poiNotes => 'الملاحظات';

  @override
  String get poiFuel => 'محطة وقود';

  @override
  String get poiHospital => 'مستشفى';

  @override
  String get poiLibrary => 'مكتبة';

  @override
  String get poiCreate => 'إنشاء نقطة اهتمام';

  @override
  String get poiSave => 'حفظ التغييرات';

  @override
  String get poiCancel => 'إلغاء';

  @override
  String get poiRequired => 'هذا الحقل مطلوب';

  @override
  String get poiInvalidCoordinate => 'أدخل إحداثيات صحيحة';

  @override
  String get poiNameLimit => 'الحد الأقصى ٢٠٠ حرف';

  @override
  String get poiNotesLimit => 'الحد الأقصى ٢٠٠٠ حرف';

  @override
  String get poiSelectLocation => 'حدد الموقع على الخريطة';

  @override
  String get poiConfirmLocation => 'تأكيد الموقع';

  @override
  String get poiDeleteTitle => 'حذف نقطة الاهتمام';

  @override
  String get poiDeleteMessage => 'هل أنت متأكد أنك تريد حذف نقطة الاهتمام؟';

  @override
  String get poiNotFound => 'نقطة الاهتمام غير موجودة';

  @override
  String get poiDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get poiDiscardMessage => 'لم يتم حفظ التغييرات. هل تريد المغادرة؟';

  @override
  String get poiDiscard => 'تجاهل';

  @override
  String get poiImportTitle => 'رفع نقاط الاهتمام بالجملة';

  @override
  String get poiImportSubtitle =>
      'قم برفع نقاط اهتمام متعددة باستخدام قالب الإكسل';

  @override
  String get poiUploadStep => 'رفع الملف';

  @override
  String get poiValidate => 'التحقق';

  @override
  String get poiPreview => 'المعاينة';

  @override
  String get poiConfirm => 'تأكيد';

  @override
  String get poiTemplate => 'تنزيل القالب';

  @override
  String get poiBrowse => 'استعراض الملفات';

  @override
  String get poiFileHint => 'اختر ملف إكسل للاستيراد';

  @override
  String get poiFileLimits =>
      'الصيغة المدعومة: .xlsx\nالحد الأقصى لحجم الملف: 20MB\nالحد الأقصى للسجلات: 5000';

  @override
  String get poiValidationTitle => 'نتائج التحقق';

  @override
  String get poiPreviewTitle => 'معاينة نقاط الاهتمام';

  @override
  String get poiValid => 'صحيح';

  @override
  String get poiInvalid => 'غير صحيح';

  @override
  String get poiDuplicate => 'مكرر';

  @override
  String get poiAll => 'الكل';

  @override
  String get poiPrevious => 'السابق';

  @override
  String get poiValidOnly =>
      'سيتم استيراد السجلات الصحيحة فقط. لن يتم إنشاء السجلات غير الصحيحة أو المكررة.';

  @override
  String get poiDropTitle => 'اسحب الملفات هنا أو انقر للاستعراض';

  @override
  String poiDropHint(String format, int size) {
    return '$format بحد أقصى $size ميجابايت';
  }

  @override
  String get poiFormatLabel => 'الصيغة المدعومة:';

  @override
  String get poiMaxSizeLabel => 'الحد الأقصى لحجم الملف:';

  @override
  String get poiMaxRecordsLabel => 'الحد الأقصى للسجلات:';

  @override
  String poiSizeMegabytes(int size) {
    return '${size}MB';
  }

  @override
  String get poiRemoveFile => 'إزالة الملف';

  @override
  String poiValidationDescription(String fileName) {
    return 'مراجعة نتائج التحقق لكل سجل في الملف $fileName';
  }

  @override
  String poiValidationSummary(int valid, int invalid) {
    return '$valid سجلاً صحيحاً جاهز للاستيراد. $invalid سجلات تحتوي على أخطاء ولن يتم استيرادها.';
  }

  @override
  String get poiPreviewDescription =>
      'راجع نقاط الاهتمام الصحيحة قبل استيرادها.';

  @override
  String poiTotalRecords(int count) {
    return 'إجمالي $count poi';
  }

  @override
  String get poiImportDoneDescription =>
      'قم برفع نقاط اهتمام متعددة باستخدام قالب الإكسل المحدد مسبقًا';

  @override
  String get poiImportSucceeded => 'تم تنزيل بنجاح';

  @override
  String get poiImportFailed => 'فشلت';

  @override
  String get poiImportDuplicates => 'مكررة';

  @override
  String get poiIssueNameRequired => 'الاسم مطلوب';

  @override
  String get poiIssueNameTooLong => 'يجب ألا يتجاوز الاسم 200 حرف';

  @override
  String get poiIssueLatitude => 'يجب أن يكون خط العرض بين -90 و90';

  @override
  String get poiIssueLongitude => 'يجب أن يكون خط الطول بين -180 و180';

  @override
  String get poiIssueIcon => 'الأيقونة غير معروفة';

  @override
  String get poiIssueNotesTooLong => 'يجب ألا تتجاوز الملاحظات 2000 حرف';

  @override
  String get poiIssueDuplicate => 'مكرر في الملف أو موجود مسبقاً';

  @override
  String get poiImportComplete => 'اكتمل استيراد نقاط الاهتمام';

  @override
  String get poiTotal => 'إجمالي السجلات';

  @override
  String get poiImported => 'تم الاستيراد';

  @override
  String get poiSkipped => 'لم يتم الاستيراد';

  @override
  String get poiShowPoints => 'عرض النقاط على الخريطة';

  @override
  String get poiInvalidFile =>
      'تعذر قراءة الملف. استخدم قالب XLSX، بحد أقصى 20MB و5000 سجل.';

  @override
  String get poiFileSaved => 'تم حفظ الملف';

  @override
  String get poiFileError => 'تعذر حفظ الملف. حاول مرة أخرى.';

  @override
  String get poiReason => 'السبب';

  @override
  String get poiInvalidRow =>
      'تحقق من الاسم والإحداثيات والأيقونة وطول الملاحظات';

  @override
  String get poiStatus => 'الحالة';
}
