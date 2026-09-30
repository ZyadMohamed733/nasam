import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_list_row.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_summary.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';
import 'package:nasam/shared/widgets/map_sheet_header.dart';

import '../../helpers/poi_screen.dart';

/// The open POI sheet measured against "POI – open" (`647:8266`) and its row
/// (`507:16775`) in `design_exports/nasam_mobile_2/poi_nodes.json`, on the
/// design's own 402×874 frame.
void main() {
  const tolerance = .5;
  Matcher about(double value) => moreOrLessEquals(value, epsilon: tolerance);

  Finder inSheet(Finder finder) =>
      find.descendant(of: find.byType(PoiSummary), matching: finder);
  Rect rectOf(WidgetTester tester, Finder finder) =>
      tester.getRect(inSheet(finder).first);

  Future<void> openSheet(WidgetTester tester, String language) async {
    await pumpPoiPage(tester, language: language);
    await tester.tap(find.text(language == 'ar' ? 'عرض' : 'Show'));
    await tester.pumpAndSettle();
  }

  for (final language in ['ar', 'en']) {
    final rtl = language == 'ar';

    testWidgets('$language: the open sheet has the design geometry', (
      tester,
    ) async {
      await openSheet(tester, language);
      final sheet = tester.getRect(find.byType(PoiSummary));
      expect(sheet.width, about(402));

      // Handle: a 56×3 bar, centred, 12 down its 34 strip — the JSON pins
      // the bar (175:4142) at y 12 with a bottom constraint, not centred.
      final bar = rectOf(tester, find.byKey(MapSheetHandle.barKey));
      expect(bar.size.width, about(56));
      expect(bar.size.height, about(3));
      expect(bar.center.dx, about(sheet.center.dx));
      expect(bar.top - sheet.top, about(12));

      // Header row: 24 tall, 16 below the 34 strip and 16 in from each side.
      final title = rectOf(tester, find.byKey(MapSheetHeader.titleRowKey));
      expect(title.height, about(24));
      expect(title.top - sheet.top, about(34 + 16));
      expect(title.left - sheet.left, about(16));
      expect(sheet.right - title.right, about(16));
      final action = rectOf(tester, find.byKey(PoiSummary.headerActionKey));
      expect(action.size.width, about(33));
      expect(action.size.height, about(20));
      expect(action.center.dy, about(title.center.dy));
      expect(rtl ? action.left : sheet.right - action.right, about(16));

      // Search: 40 × 370, 8 under the header row.
      final search = rectOf(tester, find.byKey(AppTextField.searchBoxKey));
      expect(search.height, about(40));
      expect(search.width, about(370));
      expect(search.left - sheet.left, about(16));
      expect(search.top - title.bottom, about(8));

      // Buttons: 40 tall in the 54 band 4 under the search (7 above and
      // below each button); add 179 on the end half, the transfer pair
      // 87.5 each on the start half, 4 apart and 4 in from the band's sides.
      final add = rectOf(tester, find.byKey(PoiSummary.addKey));
      final upload = rectOf(tester, find.byKey(PoiSummary.uploadKey));
      final download = rectOf(tester, find.byKey(PoiSummary.downloadKey));
      for (final button in [add, upload, download]) {
        expect(button.height, about(40));
        expect(button.top - search.bottom, about(4 + 7));
      }
      expect(add.width, about(179));
      expect(upload.width, about(87.5));
      expect(download.width, about(87.5));
      if (rtl) {
        expect(sheet.right - upload.right, about(16 + 4));
        expect(upload.left - download.right, about(4));
        expect(download.left - add.right, about(4));
        expect(add.left - sheet.left, about(16 + 4));
      } else {
        expect(upload.left - sheet.left, about(16 + 4));
        expect(download.left - upload.right, about(4));
        expect(add.left - download.right, about(4));
        expect(sheet.right - add.right, about(16 + 4));
      }

      // Rows: 44 × 370, 4 under the band, 8 apart; a 36 icon box.
      final rows = inSheet(find.byKey(PoiListRow.rowKey));
      expect(rows, findsAtLeastNWidgets(2));
      final first = tester.getRect(rows.at(0));
      final second = tester.getRect(rows.at(1));
      for (final row in [first, second]) {
        expect(row.height, about(44));
        expect(row.width, about(370));
        expect(row.left - sheet.left, about(16));
      }
      expect(first.top - (add.bottom + 7), about(4));
      expect(second.top - first.bottom, about(8));
      final iconBox = rectOf(tester, find.byKey(PoiListRow.iconBoxKey));
      expect(iconBox.size, const Size(36, 36));
      expect(iconBox.center.dy, about(first.center.dy));
      expect(
        rtl ? first.right - iconBox.right : iconBox.left - first.left,
        about(12),
      );
    });
  }

  testWidgets('the sheet draws the design colours', (tester) async {
    await openSheet(tester, 'ar');

    BoxDecoration decorationOf(Finder finder) =>
        switch (tester.widget(inSheet(finder).first)) {
          DecoratedBox(:final decoration) ||
          Container(
            decoration: final Decoration decoration,
          ) => decoration as BoxDecoration,
          final widget => throw StateError('no decoration on $widget'),
        };

    final search = decorationOf(find.byKey(AppTextField.searchBoxKey));
    expect(search.color, AppColors.inputFill);
    expect((search.border! as Border).top.color, AppColors.neutral200);
    expect(search.borderRadius, BorderRadius.circular(10));

    final row = tester.widget<Material>(
      inSheet(find.byKey(PoiListRow.rowKey)).first,
    );
    final rowShape = row.shape! as RoundedRectangleBorder;
    expect(row.color, AppColors.neutralWhite);
    expect(rowShape.side.color, AppColors.neutral200);
    expect(rowShape.side.width, 1);
    expect(rowShape.borderRadius, BorderRadius.circular(8));

    final iconBox = decorationOf(find.byKey(PoiListRow.iconBoxKey));
    expect(iconBox.color, AppColors.bluePurple25);
    expect(iconBox.borderRadius, BorderRadius.circular(8));

    final add = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(PoiSummary.addKey),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(add.style!.backgroundColor!.resolve({}), AppColors.bluePurple700);

    final handle = decorationOf(find.byKey(MapSheetHandle.barKey));
    expect(handle.color, AppColors.neutral150Handle);
  });

  group('the small controls answer touches across 48', () {
    testWidgets('the close icon, from 22 above its centre', (tester) async {
      await openSheet(tester, 'ar');
      final close = tester.getRect(find.byKey(PoiSummary.headerActionKey));
      expect(close.size, const Size(33, 20));
      await tester.tapAt(close.center.translate(0, -22));
      await tester.pumpAndSettle();
      expect(find.text('عرض'), findsOneWidget, reason: 'the sheet closed');
    });

    testWidgets('the menu dots, from 20 beside and below them', (tester) async {
      await openSheet(tester, 'en');
      final menu = tester.getRect(
        find.byTooltip('Point of interest actions').first,
      );
      expect(menu.size, const Size(16, 16));
      await tester.tapAt(menu.center.translate(-20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget, reason: 'the actions opened');
    });
  });
}
