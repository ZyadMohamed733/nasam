import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  /// Formats a Gregorian date using a pattern.
  static String formatGregorian(
    DateTime date, [
    String pattern = 'yyyy-MM-dd',
    Locale? locale,
  ]) {
    return DateFormat(pattern, locale?.toLanguageTag()).format(date);
  }

  /// Converts a Gregorian date to Umm al-Qura Hijri components.
  ///
  /// Saudi Arabia's official calendar is Umm al-Qura, a *published tabular*
  /// calendar rather than an arithmetic one. The `hijri` package carries that
  /// table; arithmetic Julian-day approximations drift from it by one to two
  /// days, which is a correctness bug when a date has to match an official
  /// record such as an inspection expiry or a violation date.
  static HijriCalendar toHijri(DateTime date) =>
      HijriCalendar.fromDate(date);

  /// Returns a localised Hijri string, e.g. `15 رمضان 1447 هـ`.
  static String formatHijri(DateTime date, {required Locale locale}) {
    final isArabic = locale.languageCode == 'ar';
    final hijri = toHijri(date);

    // A month outside 1..12 means the conversion failed. Degrade to a numeric
    // form rather than throwing a RangeError on the month-name lookup.
    if (hijri.hMonth < 1 || hijri.hMonth > 12) {
      final month = hijri.hMonth.toString().padLeft(2, '0');
      final day = hijri.hDay.toString().padLeft(2, '0');
      return '${hijri.hYear}-$month-$day';
    }

    HijriCalendar.setLocal(isArabic ? 'ar' : 'en');
    final monthName = hijri.getLongMonthName();
    final suffix = isArabic ? 'هـ' : 'AH';
    return '${hijri.hDay} $monthName ${hijri.hYear} $suffix';
  }
}
