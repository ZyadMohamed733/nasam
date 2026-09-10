import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/extensions/date_extensions.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';

void main() {
  final now = DateTime.utc(2026, 3, 20, 12);

  Future<String> relative(
    WidgetTester tester,
    Duration ago,
    Locale locale,
  ) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Builder(
          builder: (context) {
            text = now.subtract(ago).toRelativeTime(context, now: now);
            return const SizedBox();
          },
        ),
      ),
    );
    return text;
  }

  group('English', () {
    testWidgets('uses singular and plural forms', (tester) async {
      expect(await relative(tester, Duration.zero, const Locale('en')),
          'Just now');
      expect(await relative(tester, const Duration(minutes: 1), const Locale('en')),
          '1 minute ago');
      expect(await relative(tester, const Duration(minutes: 5), const Locale('en')),
          '5 minutes ago');
      expect(await relative(tester, const Duration(hours: 1), const Locale('en')),
          '1 hour ago');
      expect(await relative(tester, const Duration(days: 1), const Locale('en')),
          '1 day ago');
      expect(await relative(tester, const Duration(days: 14), const Locale('en')),
          '2 weeks ago');
    });

    testWidgets('falls back to an absolute date beyond 30 days', (tester) async {
      expect(
        await relative(tester, const Duration(days: 40), const Locale('en')),
        '2026-02-08',
      );
    });
  });

  // Arabic has six plural categories, and the dual form carries no number word
  // at all -- the thing `count == 1 ? a : b` could never express.
  group('Arabic', () {
    testWidgets('uses the dual form with no number word', (tester) async {
      expect(
        await relative(tester, const Duration(days: 2), const Locale('ar')),
        'منذ يومين',
      );
      expect(
        await relative(tester, const Duration(hours: 2), const Locale('ar')),
        'منذ ساعتين',
      );
    });

    testWidgets('distinguishes few (3-10) from many (11-99)', (tester) async {
      expect(
        await relative(tester, const Duration(days: 3), const Locale('ar')),
        'منذ 3 أيام',
      );
      expect(
        await relative(tester, const Duration(minutes: 15), const Locale('ar')),
        'منذ 15 دقيقة',
      );
    });

    testWidgets('uses the singular form for one', (tester) async {
      expect(
        await relative(tester, const Duration(days: 1), const Locale('ar')),
        'منذ يوم',
      );
    });
  });
}
