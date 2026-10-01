import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';

import '../../helpers/poi_import_screen.dart';

/// Tap targets on every bulk-upload step. The design draws page buttons 32,
/// filter chips 32, the template and browse buttons 40 and the bar's 44;
/// each must still measure 48.
///
/// Text contrast is not checked: the design's secondary grey (#818181) is
/// 3.9:1 on white — see docs/backlog.md ("Secondary grey text under AA").
void main() {
  final steps = <String, Future<void> Function(PoiImportCubit)>{
    'upload': (cubit) => cubit.pick(),
    'validation': (cubit) async {
      await cubit.pick();
      await cubit.validate();
    },
    'preview': (cubit) async {
      await cubit.pick();
      await cubit.validate();
      cubit.preview();
    },
    'confirm': (cubit) async {
      await cubit.pick();
      await cubit.validate();
      cubit.preview();
      await cubit.confirm();
    },
  };

  for (final MapEntry(key: step, value: reach) in steps.entries) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('$step, $language ${dark ? 'dark' : 'light'}', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          final (cubit, _) = await pumpPoiImportPage(
            tester,
            language: language,
            dark: dark,
          );
          await reach(cubit);
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          semantics.dispose();
        });
      }
    }
  }
}
