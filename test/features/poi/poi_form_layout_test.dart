import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/pages/poi_details_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon_picker.dart';
import 'package:nasam/shared/widgets/app_dashed_box.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_form_card.dart';
import 'package:nasam/shared/widgets/app_info_section.dart';
import 'package:nasam/shared/widgets/app_map_preview.dart';
import 'package:nasam/shared/widgets/app_page_header.dart';

import '../../helpers/poi_form_screens.dart';

/// Create (`647:7879`), Edit (`647:7930`), View (`647:7898`) and the icon
/// picker (`647:8257`) measured against
/// `design_exports/nasam_mobile_2/poi_nodes.json` on the 402×874 frame.
///
/// The design frames start with a 44 status bar the test surface does not
/// have, so every design y here is the design's less 44.
void main() {
  Matcher about(double value) => moreOrLessEquals(value, epsilon: .5);
  void expectRect(Rect actual, Rect design, String what) {
    for (final (name, a, d) in [
      ('left', actual.left, design.left),
      ('top', actual.top, design.top),
      ('width', actual.width, design.width),
      ('height', actual.height, design.height),
    ]) {
      expect(a, about(d), reason: '$what $name');
    }
  }

  Rect rectOf(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));
  Rect input(WidgetTester tester, Key key) => tester.getRect(
    find.descendant(of: find.byKey(key), matching: find.byType(InputDecorator)),
  );

  for (final screen in [PoiFormScreen.create, PoiFormScreen.edit]) {
    testWidgets('${screen.name}: header, card, fields and bar', (tester) async {
      await pumpPoiFormScreen(tester, screen);

      // Header (647:7882): 71 tall, the chevron at the start (right).
      expectRect(
        tester.getRect(find.byType(AppPageHeader)),
        const Rect.fromLTWH(0, 0, 402, 71),
        'header',
      );
      expectRect(
        rectOf(tester, AppPageHeader.backKey),
        const Rect.fromLTWH(362, 12, 24, 24),
        'back chevron',
      );

      // Card (734:9467 at 16,115): 370 wide, content 338 from x 32.
      final card = tester.getRect(find.byType(AppFormCard));
      expect(card.left, about(16));
      expect(card.top, about(115 - 44));
      expect(card.width, about(370));
      final top = card.top;

      // Name (539:13753 at +85; its input at +28).
      expectRect(
        input(tester, PoiFormLayout.nameKey),
        Rect.fromLTWH(32, top + 85 + 28, 338, 44),
        'name input',
      );

      // Location (539:13754 at +175): the dashed box, 338×289, at +28.
      final box = rectOf(tester, PoiFormLayout.locationBoxKey);
      expectRect(box, Rect.fromLTWH(32, top + 175 + 28, 338, 289), 'box');
      // The map, 322×171, 8 in and 4 + 20 + 8 down.
      expectRect(
        tester.getRect(find.byType(AppMapPreview)),
        Rect.fromLTWH(40, box.top + 4 + 28, 322, 171),
        'map',
      );
      // The coordinates, 159 wide and 4 apart, latitude at the start.
      final map = tester.getRect(find.byType(AppMapPreview));
      expectRect(
        input(tester, PoiFormLayout.latitudeKey),
        Rect.fromLTWH(203, map.bottom + 4 + 28, 159, 44),
        'latitude input',
      );
      expectRect(
        input(tester, PoiFormLayout.longitudeKey),
        Rect.fromLTWH(40, map.bottom + 4 + 28, 159, 44),
        'longitude input',
      );
      // The full-screen button, 12 down and 7 in from the map's end.
      expectRect(
        rectOf(tester, AppMapPreview.fullscreenKey),
        Rect.fromLTWH(47, map.top + 12, 40, 40),
        'full screen',
      );

      // Icon (539:13769 at +510): a 40 box at +28.
      expectRect(
        rectOf(tester, PoiFormLayout.iconKey),
        Rect.fromLTWH(32, top + 510 + 28, 338, 40),
        'icon box',
      );
      // Notes (539:13777 at +596): its input at +28.
      final notes = input(tester, PoiFormLayout.notesKey);
      expect(notes.top, about(top + 596 + 28));
      expect(notes.width, about(338));

      // Bottom bar (647:7895): 60 tall, cancel 99×44 at 16, primary fills.
      final bar = tester.getRect(find.byType(AppFormBottomBar));
      expectRect(bar, const Rect.fromLTWH(0, 874 - 60, 402, 60), 'bar');
      expectRect(
        rectOf(tester, AppFormBottomBar.cancelKey),
        Rect.fromLTWH(16, bar.top + 8, 99, 44),
        'cancel',
      );
      expectRect(
        rectOf(tester, AppFormBottomBar.primaryKey),
        Rect.fromLTWH(123, bar.top + 8, 263, 44),
        'primary',
      );
    });
  }

  testWidgets('view: header with edit, map, four sections', (tester) async {
    await pumpPoiFormScreen(tester, PoiFormScreen.view);
    expectRect(
      rectOf(tester, PoiDetailsPage.editKey),
      const Rect.fromLTWH(16, 12, 44, 44),
      'edit button',
    );
    // The card (647:7913 at 16,115); its map at 0,0.
    expectRect(
      rectOf(tester, PoiViewLayout.mapKey),
      const Rect.fromLTWH(16, 115 - 44, 370, 112),
      'map',
    );
    expectRect(
      rectOf(tester, AppMapPreview.fullscreenKey),
      // 7 from the map's end: its left, in RTL.
      const Rect.fromLTWH(16 + 7, 115 - 44 + 12, 40, 40),
      'full screen',
    );
    final sections = find.byType(AppInfoSection);
    // At card y 120, 242, 364, 486: 114, 114, 114 and 164 tall.
    for (final (index, y, height) in [
      (0, 120.0, 114.0),
      (1, 242.0, 114.0),
      (2, 364.0, 114.0),
      (3, 486.0, 164.0),
    ]) {
      expectRect(
        tester.getRect(sections.at(index)),
        Rect.fromLTWH(16, 115 - 44 + y, 370, height),
        'section $index',
      );
    }
    final basic = tester.getRect(sections.at(0));
    expectRect(
      rectOf(tester, PoiViewLayout.nameKey),
      Rect.fromLTWH(24, basic.top + 38, 354, 60),
      'name value',
    );
    final location = tester.getRect(sections.at(1));
    expectRect(
      rectOf(tester, PoiViewLayout.longitudeKey),
      Rect.fromLTWH(24 + 182, location.top + 38, 172, 60),
      'longitude value',
    );
    expectRect(
      rectOf(tester, PoiViewLayout.latitudeKey),
      Rect.fromLTWH(24, location.top + 38, 172, 60),
      'latitude value',
    );
    final notes = tester.getRect(sections.at(3));
    expectRect(
      rectOf(tester, PoiViewLayout.notesKey),
      Rect.fromLTWH(24, notes.top + 38, 354, 110),
      'notes value',
    );
  });

  testWidgets('icon picker: handle, heading, 370-wide rows', (tester) async {
    await pumpPoiFormScreen(tester, PoiFormScreen.edit);
    await tester.tap(find.byKey(PoiFormLayout.iconKey));
    await tester.pumpAndSettle();
    final sheet = tester.getRect(find.byType(PoiIconPicker));
    // The heading (304:14800) 34 down, its text 32 in from the right.
    final heading = tester.getRect(find.text('الأيقونة').last);
    expect(heading.right, about(402 - 32));
    expect(heading.center.dy, about(sheet.top + 34 + 16));
    for (final (index, row)
        in find
            .byWidgetPredicate(
              (w) => w.key.toString().contains('poi-icon-picker'),
            )
            .evaluate()
            .indexed) {
      final rect = tester.getRect(find.byWidget(row.widget));
      expectRect(
        rect,
        Rect.fromLTWH(16, sheet.top + 34 + 32 + index * 48, 370, 48),
        'row $index',
      );
    }
    expect(
      find.byWidgetPredicate(
        (w) => w.key.toString().contains('poi-icon-picker'),
      ),
      findsNWidgets(4),
    );
    expect(find.byType(AppDashedBox), findsOneWidget);
  });
}
