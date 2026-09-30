import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';

import '../../helpers/poi_form_screens.dart';

/// Tap targets on Create, Edit, View and the icon picker. The design draws
/// the back chevron 24, the edit button 44, the full-screen button 40 and
/// the bar's buttons 44; each must still measure 48.
///
/// Text contrast is not checked: the design's secondary grey (#818181) is
/// 3.9:1 on white — see docs/backlog.md ("Secondary grey text under AA").
void main() {
  Future<void> meetsTapTargets(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  for (final dark in [false, true]) {
    for (final language in ['ar', 'en']) {
      final variant = '$language ${dark ? 'dark' : 'light'}';
      for (final screen in PoiFormScreen.values) {
        testWidgets('${screen.name}, $variant', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpPoiFormScreen(
            tester,
            screen,
            language: language,
            dark: dark,
          );
          await meetsTapTargets(tester);
          semantics.dispose();
        });
      }
      testWidgets('icon picker, $variant', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpPoiFormScreen(
          tester,
          PoiFormScreen.edit,
          language: language,
          dark: dark,
        );
        await tester.tap(find.byKey(PoiFormLayout.iconKey));
        await tester.pumpAndSettle();
        await meetsTapTargets(tester);
        semantics.dispose();
      });
    }
  }
}
