import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/utils/app_date_utils.dart';

void main() {
  /// Published Umm al-Qura anchors — the calendar Saudi Arabia actually uses.
  /// The previous hand-rolled Julian-day approximation missed every one of
  /// these by one to two days, including placing Eid al-Fitr 1445 on
  /// 30 Ramadan.
  const ummAlQuraAnchors = <String, (int, int, int)>{
    '2023-07-19': (1445, 1, 1), // 1 Muharram 1445
    '2024-03-11': (1445, 9, 1), // 1 Ramadan 1445
    '2024-04-10': (1445, 10, 1), // 1 Shawwal 1445 — Eid al-Fitr
    '2024-07-07': (1446, 1, 1), // 1 Muharram 1446
    '2025-03-01': (1446, 9, 1), // 1 Ramadan 1446
    '2025-03-30': (1446, 10, 1), // 1 Shawwal 1446 — Eid al-Fitr
    '2026-02-18': (1447, 9, 1), // 1 Ramadan 1447
  };

  group('toHijri matches the official Umm al-Qura calendar', () {
    ummAlQuraAnchors.forEach((gregorian, expected) {
      test('$gregorian converts to ${expected.$1}-${expected.$2}-${expected.$3}',
          () {
        final hijri = AppDateUtils.toHijri(DateTime.parse(gregorian));
        expect(
          (hijri.hYear, hijri.hMonth, hijri.hDay),
          expected,
        );
      });
    });
  });

  group('formatHijri', () {
    test('renders Arabic month names under an Arabic locale', () {
      final formatted = AppDateUtils.formatHijri(
        DateTime.utc(2026, 2, 18),
        locale: const Locale('ar'),
      );
      expect(formatted, '1 رمضان 1447 هـ');
    });

    test('renders transliterated month names under an English locale', () {
      final formatted = AppDateUtils.formatHijri(
        DateTime.utc(2026, 2, 18),
        locale: const Locale('en'),
      );
      expect(formatted, contains('1447'));
      expect(formatted, contains('AH'));
      expect(formatted, contains('Ramadan'));
    });

    // Takes a Locale rather than a bool, so a third locale does not break it.
    test('an unrelated locale still formats without throwing', () {
      expect(
        () => AppDateUtils.formatHijri(
          DateTime.utc(2026, 2, 18),
          locale: const Locale('fr'),
        ),
        returnsNormally,
      );
    });
  });

  group('formatGregorian', () {
    test('formats with the default pattern', () {
      expect(
        AppDateUtils.formatGregorian(DateTime.utc(2026, 3, 5)),
        '2026-03-05',
      );
    });
  });
}
