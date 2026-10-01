import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_status_tones.dart';
import 'package:nasam/features/poi/domain/entities/poi_import_row.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_data_table.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_pagination.dart';
import 'package:nasam/shared/widgets/app_status_chip.dart';

import '../../helpers/poi_import_screen.dart';

void main() {
  Future<void> openValidation(
    WidgetTester tester, {
    String language = 'ar',
  }) async {
    final (cubit, _) = await pumpPoiImportPage(tester, language: language);
    await cubit.pick();
    await cubit.validate();
    await tester.pumpAndSettle();
  }

  AppStatusChip chip(WidgetTester tester, String key) => tester
      .widget<AppStatusChip>(find.byKey(ValueKey('poi-import-filter-$key')));

  testWidgets('four filters with their counts, "all" selected and first', (
    tester,
  ) async {
    await openValidation(tester);
    expect(find.text('نتائج التحقق'), findsOneWidget);
    expect(find.textContaining('POIs.xlsx'), findsOneWidget);
    final all = chip(tester, 'all');
    expect((all.tone, all.count, all.selected), (AppTone.info, 24, true));
    expect(chip(tester, 'valid').count, 20);
    expect(chip(tester, 'invalid').tone, AppTone.danger);
    expect(chip(tester, 'invalid').count, 3);
    expect(chip(tester, 'duplicate').count, 1);
    final allRect = tester.getRect(
      find.byKey(const ValueKey('poi-import-filter-all')),
    );
    final validRect = tester.getRect(
      find.byKey(const ValueKey('poi-import-filter-valid')),
    );
    expect(allRect.left, greaterThan(validRect.left), reason: 'RTL');
  });

  testWidgets('a filter narrows the table; invalid rows show their reasons '
      'and are outlined', (tester) async {
    await openValidation(tester);
    await tester.tap(find.byKey(const ValueKey('poi-import-filter-invalid')));
    await tester.pumpAndSettle();
    final table = tester.widget<AppDataTable>(find.byType(AppDataTable));
    expect(table.rows, hasLength(3));
    expect(table.rows.every((r) => r.flagged), isTrue);
    expect(table.columns.last.label, 'السبب');
    expect(find.text('يجب أن يكون خط العرض بين -90 و90'), findsOneWidget);
    expect(find.text('الاسم مطلوب'), findsOneWidget);
  });

  testWidgets('pages through the rows', (tester) async {
    await openValidation(tester);
    expect(
      tester.widget<AppDataTable>(find.byType(AppDataTable)).rows,
      hasLength(10),
    );
    await tester.tap(find.byKey(AppPagination.pageKey(2)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppDataTable>(find.byType(AppDataTable)).rows,
      hasLength(4),
    );
    expect(find.text('إجمالي 24 poi'), findsOneWidget);
  });

  testWidgets('the summary line and the bar: previous as text, preview on', (
    tester,
  ) async {
    await openValidation(tester);
    expect(find.textContaining('20 سجلاً صحيحاً'), findsOneWidget);
    expect(find.textContaining('4 سجلات'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(AppFormBottomBar.cancelKey),
        matching: find.byType(TextButton),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AppButton>(find.byKey(AppFormBottomBar.primaryKey))
          .onPressed,
      isNotNull,
    );
  });

  test('statuses keep their order: all, valid, invalid, duplicate', () {
    expect(PoiRowStatus.values, [
      PoiRowStatus.valid,
      PoiRowStatus.invalid,
      PoiRowStatus.duplicate,
    ]);
  });
}
