import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/poi_sheet_colors.dart';
import 'package:nasam/features/poi/domain/entities/poi_draft.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon_picker.dart';
import 'package:nasam/shared/widgets/map_sheet_header.dart';

import '../../helpers/widget_harness.dart';

void main() {
  Future<PoiIcon?> Function() openPicker(
    WidgetTester tester, {
    PoiIcon? selected,
    Locale locale = const Locale('ar'),
  }) {
    PoiIcon? result;
    var done = false;
    return () async {
      await pumpInApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showPoiIconPicker(context, selected: selected);
              done = true;
            },
            child: const Text('open'),
          ),
        ),
        locale: locale,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return done ? result : null;
    };
  }

  testWidgets('handle, heading, then four 48 rows of icon and name', (
    tester,
  ) async {
    await openPicker(tester, selected: PoiIcon.fuel)();
    final sheet = tester.getRect(find.byType(PoiIconPicker));
    expect(find.byType(MapSheetHandle), findsOneWidget);
    final heading = tester.getRect(find.text('الأيقونة'));
    expect(heading.right, moreOrLessEquals(sheet.right - 32, epsilon: .5));
    var previous = sheet.top + 34 + 32;
    for (final icon in PoiIcon.values) {
      final row = tester.getRect(find.byKey(PoiIconPicker.rowKey(icon)));
      expect(row.height, 48);
      expect(row.width, sheet.width - 32);
      expect(row.top, moreOrLessEquals(previous, epsilon: .5));
      previous = row.bottom;
    }
    for (final name in ['موقع', 'مستشفى', 'مكتبة', 'محطة وقود']) {
      expect(find.text(name), findsOneWidget);
    }
    final fuel = tester.widget<Material>(
      find.descendant(
        of: find.byKey(PoiIconPicker.rowKey(PoiIcon.fuel)),
        matching: find.byType(Material),
      ),
    );
    expect(fuel.color, PoiSheetColors.light.rowSelectedFill);
    expect(
      tester.getSemantics(find.byKey(PoiIconPicker.rowKey(PoiIcon.fuel))),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
  });

  testWidgets('returns the tapped icon', (tester) async {
    PoiIcon? picked;
    await pumpInApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked = await showPoiIconPicker(context),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hospital'));
    await tester.pumpAndSettle();
    expect(picked, PoiIcon.hospital);
    expect(find.byType(PoiIconPicker), findsNothing);
  });

  testWidgets('meets the tap-target guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await openPicker(tester)();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
