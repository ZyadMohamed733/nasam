import 'package:intl/intl.dart';

class AppDateUtils {
  /// Formats a Gregorian date using a pattern.
  static String formatGregorian(DateTime date, [String pattern = 'yyyy-MM-dd']) {
    return DateFormat(pattern).format(date);
  }

  /// Converts Gregorian date to Hijri components: {year, month, day}.
  /// Uses a standard astronomical Julian Day approximation algorithm.
  static Map<String, int> gregorianToHijri(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = (a / 4).floor();
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();
    
    double jd = c + day + e + f - 1524.5;

    int l = (jd - 1948440 + 10632).floor();
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    
    int j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() + 
            (l / 5670).floor() * ((43 * l) / 15238).floor();
            
    l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() - 
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
        
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    return {
      'year': hYear,
      'month': hMonth,
      'day': hDay,
    };
  }

  /// Returns localized Hijri string, e.g. "1447-10-15" or Month names.
  static String formatHijri(DateTime date, {bool isArabic = false}) {
    final hijri = gregorianToHijri(date);
    final hDay = hijri['day']!;
    final hMonth = hijri['month']!;
    final hYear = hijri['year']!;

    if (isArabic) {
      final arabicMonths = [
        'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
        'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
        'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
      ];
      final monthName = arabicMonths[hMonth - 1];
      return '$hDay $monthName $hYear هـ';
    } else {
      final englishMonths = [
        'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' ath-Thani",
        'Jumada al-Ula', 'Jumada al-Akhirah', 'Rajab', "Sha'ban",
        'Ramadan', 'Shawwal', "Dhu al-Qadah", "Dhu al-Hijjah"
      ];
      final monthName = englishMonths[hMonth - 1];
      return '$hDay $monthName $hYear AH';
    }
  }
}
