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
}
