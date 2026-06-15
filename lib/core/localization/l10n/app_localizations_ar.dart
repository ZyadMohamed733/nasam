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
  String get validationInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get validationPasswordWeak =>
      'يجب أن تكون كلمة المرور مكونة من 8 رموز على الأقل وتحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص.';

  @override
  String get validationInvalidPhone => 'يرجى إدخال رقم هاتف سعودي صحيح.';
}
