import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/domain/entities/poi_draft.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon_picker.dart';

import '../../helpers/poi_form_screens.dart';

/// Create (empty and filled), Edit, View and the icon picker on the 402×874
/// design frame, across Arabic/English, light/dark and text scale 1.0/1.5.
///
/// Written to `goldens/poi_form/<screen>_<language>_<theme>_<scale>.png`.
void main() {
  Finder input(Key key) =>
      find.descendant(of: find.byKey(key), matching: find.byType(EditableText));

  /// The design's sample point (Create POI, `647:7879`).
  Future<void> fill(WidgetTester tester, String language) async {
    await tester.enterText(
      input(PoiFormLayout.nameKey),
      language == 'ar' ? 'المستودع الرئيسي - شمال الرياض' : 'Main warehouse',
    );
    await tester.enterText(input(PoiFormLayout.latitudeKey), '24.695299');
    await tester.enterText(input(PoiFormLayout.longitudeKey), '46.672120');
    await tester.enterText(
      input(PoiFormLayout.notesKey),
      language == 'ar'
          ? 'شركة أمانة محافظة جدة هي الجهة الحكومية المسؤولة عن تنظيم '
                'وتطوير الخدمات البلدية.'
          : 'The municipal authority responsible for city services.',
    );
    await tester.ensureVisible(find.byKey(PoiFormLayout.iconKey));
    await tester.tap(find.byKey(PoiFormLayout.iconKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PoiIconPicker.rowKey(PoiIcon.fuel)));
    await tester.pumpAndSettle();
    // Back to the top, where the design frame starts.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 800));
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  final screens =
      <String, (PoiFormScreen, Future<void> Function(WidgetTester, String))>{
        'create_empty': (PoiFormScreen.create, (_, _) async {}),
        'create_filled': (PoiFormScreen.create, fill),
        'edit': (PoiFormScreen.edit, (_, _) async {}),
        'view': (PoiFormScreen.view, (_, _) async {}),
        'picker': (
          PoiFormScreen.edit,
          (tester, _) async {
            await tester.tap(find.byKey(PoiFormLayout.iconKey));
            await tester.pumpAndSettle();
          },
        ),
      };

  for (final MapEntry(key: name, value: (screen, prepare)) in screens.entries) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 1.5]) {
          final theme = dark ? 'dark' : 'light';
          final file = '${name}_${language}_${theme}_$scale';
          testWidgets(file, (tester) async {
            await pumpPoiFormScreen(
              tester,
              screen,
              language: language,
              dark: dark,
              scale: scale,
            );
            await prepare(tester, language);
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/poi_form/$file.png'),
            );
          });
        }
      }
    }
  }
}
