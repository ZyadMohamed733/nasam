import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/shared/widgets/app_data_table.dart';
import 'package:nasam/shared/widgets/app_file_drop_zone.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_page_header.dart';
import 'package:nasam/shared/widgets/app_pagination.dart';
import 'package:nasam/shared/widgets/app_status_chip.dart';
import 'package:nasam/shared/widgets/app_stepper.dart';
import 'package:nasam/shared/widgets/app_summary_tile.dart';

import '../../helpers/poi_import_screen.dart';

/// The bulk upload against `design_exports/nasam_mobile_2/poi_nodes.json` on
/// the 402×874 frame. The frames start with a 44 status bar the test
/// surface lacks, so each design y here is the design's less 44.
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

  Rect rect(WidgetTester tester, Finder finder) => tester.getRect(finder);

  /// The shell every step shares: header 71, stepper 36 at 137 (`561:12169`),
  /// content 370 wide from 16.
  void expectShell(WidgetTester tester) {
    expectRect(
      rect(tester, find.byType(AppPageHeader)),
      const Rect.fromLTWH(0, 0, 402, 71),
      'header',
    );
    expectRect(
      rect(tester, find.byType(AppStepper)),
      const Rect.fromLTWH(16, 137 - 44, 370, 36),
      'stepper',
    );
  }

  void expectBar(WidgetTester tester) {
    final bar = rect(tester, find.byType(AppFormBottomBar));
    expectRect(bar, const Rect.fromLTWH(0, 874 - 60, 402, 60), 'bar');
    expect(
      rect(tester, find.byKey(AppFormBottomBar.primaryKey)).size,
      const Size(263, 44),
    );
  }

  testWidgets('Upload (647:7950)', (tester) async {
    await pumpPoiImportPage(tester);
    expectShell(tester);
    expectBar(tester);
    // The card (561:12170) at 189, the band (561:12171) inside its border.
    final band = rect(
      tester,
      find.ancestor(
        of: find.text('الصيغة المدعومة:'),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.padding == const EdgeInsets.all(16),
        ),
      ),
    );
    expectRect(band, const Rect.fromLTWH(17, 190 - 44, 368, 94), 'band');
    // The template button (561:12172) and the drop zone (561:12184).
    final template = rect(
      tester,
      find
          .ancestor(
            of: find.text('تنزيل القالب'),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expectRect(template, Rect.fromLTWH(34, band.top + 27, 131, 40), 'template');
    expectRect(
      rect(tester, find.byType(AppFileDropZone)),
      Rect.fromLTWH(33, band.bottom + 34.6, 336, 204.8),
      'drop zone',
    );
  });

  Future<PoiImportCubit> validated(WidgetTester tester) async {
    final (cubit, _) = await pumpPoiImportPage(tester);
    await cubit.pick();
    await cubit.validate();
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('Validation (647:7969)', (tester) async {
    await validated(tester);
    expectShell(tester);
    expectBar(tester);
    // Title at 189 (561:13775), filters 56 below (561:13777), chips 11 in.
    final title = rect(tester, find.text('نتائج التحقق'));
    expect(title.top, about(189 - 44));
    expect(title.right, about(386));
    final all = rect(
      tester,
      find.byKey(const ValueKey('poi-import-filter-all')),
    );
    expectRect(all, Rect.fromLTWH(284, title.top + 56 + 11, 102, 32), 'all');
    final valid = rect(
      tester,
      find.byKey(const ValueKey('poi-import-filter-valid')),
    );
    expect(all.left - valid.right, about(4));
    // The table (561:13806) 110 under the title block's top.
    final table = rect(tester, find.byType(AppDataTable));
    expect(table.top, about(title.top + 110));
    expect(table.left, about(16));
    expect(table.width, about(370));
    final pagination = rect(tester, find.byType(AppPagination));
    expect(pagination.top, about(table.bottom));
    expect(pagination.height, about(40));
    expect(pagination.width, about(370));
  });

  testWidgets('Preview (647:7988)', (tester) async {
    final cubit = await validated(tester);
    cubit.preview();
    await tester.pumpAndSettle();
    expectShell(tester);
    expectBar(tester);
    final title = rect(tester, find.text('معاينة نقاط الاهتمام'));
    expect(title.top, about(189 - 44));
    final table = rect(tester, find.byType(AppDataTable));
    expect(table.top, about(title.top + 56));
    expect(table.width, about(370));
    // Five columns 370 wide in all: name 113, then 64.25 each.
    final header = rect(tester, find.text('اسم نقطة الاهتمام'));
    expect(header.right, lessThanOrEqualTo(386 - 12 + .5));
    final chip = rect(tester, find.byType(AppStatusChip).first);
    expect(chip.left, greaterThanOrEqualTo(16 + 12 - .5));
  });

  testWidgets('Confirm (647:8007)', (tester) async {
    final cubit = await validated(tester);
    cubit.preview();
    await cubit.confirm();
    await tester.pumpAndSettle();
    expectShell(tester);
    expect(find.byType(AppFormBottomBar), findsNothing);
    // The card (561:16904) at 189; the tiles (561:16910) 188 into it, 82
    // tall, 78.5 wide, 8 apart, info at the start.
    final tiles = find.byType(AppSummaryTile);
    final info = rect(tester, tiles.first);
    expectRect(
      info,
      const Rect.fromLTWH(16 + 16 + 259.5, 189 - 44 + 188, 78.5, 82),
      'total tile',
    );
    final warning = rect(tester, tiles.last);
    expectRect(
      warning,
      const Rect.fromLTWH(16 + 16, 189 - 44 + 188, 78.5, 82),
      'duplicates tile',
    );
  });
}
