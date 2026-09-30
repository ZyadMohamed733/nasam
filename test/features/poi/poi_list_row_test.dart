import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/poi_sheet_colors.dart';
import 'package:nasam/features/poi/domain/entities/point_of_interest.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_list_row.dart';

import '../../helpers/widget_harness.dart';

void main() {
  const point = PointOfInterest(
    id: 'poi-1',
    name: 'نقطة اهتمام باسم طويل جدا لا يتسع لسطر واحد في القائمة أبدا',
    latitude: 24.7,
    longitude: 46.7,
  );

  Future<({List<String> taps})> pumpRow(
    WidgetTester tester, {
    bool selected = false,
  }) async {
    final taps = <String>[];
    await pumpInApp(
      tester,
      PoiListRow(
        point: point,
        selected: selected,
        onSelect: () => taps.add('select'),
        onActions: () => taps.add('actions'),
      ),
      locale: const Locale('ar'),
    );
    return (taps: taps);
  }

  Rect row(WidgetTester tester) =>
      tester.getRect(find.byKey(PoiListRow.rowKey));

  testWidgets('draws 44 but selects across 48', (tester) async {
    final (:taps) = await pumpRow(tester);
    final rect = row(tester);
    expect(rect.height, 44);

    await tester.tapAt(rect.topCenter.translate(0, -1.5));
    await tester.tapAt(rect.bottomCenter.translate(0, 1.5));
    expect(taps, ['select', 'select']);
    await tester.tapAt(rect.topCenter.translate(0, -3));
    expect(taps, hasLength(2), reason: 'outside the 48');
  });

  testWidgets('the menu takes touches across 48 around the dots, even over '
      'the row', (tester) async {
    final (:taps) = await pumpRow(tester);
    final menu = tester.getRect(find.byTooltip('إجراءات'));
    expect(menu.size, const Size(16, 16));
    // RTL: the menu is at the row's left end.
    expect(menu.left - row(tester).left, 12);

    await tester.tapAt(menu.center.translate(20, 0)); // over the row
    await tester.tapAt(menu.center.translate(-20, -20)); // past its corner
    expect(taps, ['actions', 'actions']);
    await tester.tapAt(menu.center.translate(30, 0));
    expect(taps.last, 'select');
  });

  testWidgets('the name keeps to one line', (tester) async {
    await pumpRow(tester);
    final name = tester.widget<Text>(find.text(point.name));
    expect(name.maxLines, 1);
    expect(name.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected rows take the provisional selected fill', (
    tester,
  ) async {
    await pumpRow(tester, selected: true);
    expect(
      tester.widget<Material>(find.byKey(PoiListRow.rowKey)).color,
      PoiSheetColors.light.rowSelectedFill,
    );
    expect(
      tester.getSemantics(find.byKey(PoiListRow.rowKey)),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
  });
}
