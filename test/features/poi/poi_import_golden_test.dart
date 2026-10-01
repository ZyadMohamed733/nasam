import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';

import '../../helpers/poi_import_screen.dart';

/// Upload, Validation, Preview and Confirm on the 402×874 design frame,
/// across Arabic/English, light/dark and text scale 1.0/1.5.
///
/// Written to `goldens/poi_import/<step>_<language>_<theme>_<scale>.png`.
void main() {
  final steps = <String, Future<void> Function(PoiImportCubit)>{
    'upload': (_) async {},
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
        for (final scale in [1.0, 1.5]) {
          final name = '${step}_${language}_${dark ? 'dark' : 'light'}_$scale';
          testWidgets(name, (tester) async {
            final (cubit, _) = await pumpPoiImportPage(
              tester,
              language: language,
              dark: dark,
              scale: scale,
            );
            await reach(cubit);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/poi_import/$name.png'),
            );
          });
        }
      }
    }
  }
}
