import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/app_page_dots.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('AppPageDots', () {
    Future<List<double>> dotCentres(WidgetTester tester) async {
      final containers = find.descendant(
        of: find.byType(AppPageDots),
        matching: find.byType(AnimatedContainer),
      );
      return [
        for (var i = 0; i < containers.evaluate().length; i++)
          tester.getCenter(containers.at(i)).dx,
      ];
    }

    testWidgets('renders one dot per page', (tester) async {
      await pumpInApp(tester, const AppPageDots(count: 3, activeIndex: 0));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppPageDots),
          matching: find.byType(AnimatedContainer),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('the active dot is the wide one', (tester) async {
      await pumpInApp(tester, const AppPageDots(count: 3, activeIndex: 1));
      await tester.pumpAndSettle();

      final sizes = [
        for (var i = 0; i < 3; i++)
          tester.getSize(
            find
                .descendant(
                  of: find.byType(AppPageDots),
                  matching: find.byType(AnimatedContainer),
                )
                .at(i),
          ),
      ];

      expect(sizes[1].width, greaterThan(sizes[0].width));
      expect(sizes[1].width, greaterThan(sizes[2].width));
    });

    // The progression has to read the way the language does, or page two of an
    // Arabic onboarding appears to run backwards.
    testWidgets('progresses left-to-right in English', (tester) async {
      await pumpInApp(
        tester,
        const AppPageDots(count: 3, activeIndex: 0),
        locale: const Locale('en'),
      );
      await tester.pumpAndSettle();

      final centres = await dotCentres(tester);
      expect(centres[0], lessThan(centres[1]));
      expect(centres[1], lessThan(centres[2]));
    });

    testWidgets('progresses right-to-left in Arabic', (tester) async {
      await pumpInApp(
        tester,
        const AppPageDots(count: 3, activeIndex: 0),
        locale: const Locale('ar'),
      );
      await tester.pumpAndSettle();

      final centres = await dotCentres(tester);
      expect(centres[0], greaterThan(centres[1]));
      expect(centres[1], greaterThan(centres[2]));
    });
  });
}
