import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/domain/entities/poi_import_row.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/shared/widgets/app_data_table.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_status_chip.dart';

import '../../helpers/poi_import_screen.dart';

void main() {
  Future<PoiImportCubit> openPreview(WidgetTester tester) async {
    final (cubit, _) = await pumpPoiImportPage(tester);
    await cubit.pick();
    await cubit.validate();
    cubit.preview();
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('valid rows only, five columns, every status "valid"', (
    tester,
  ) async {
    await openPreview(tester);
    expect(find.text('معاينة نقاط الاهتمام'), findsOneWidget);
    final table = tester.widget<AppDataTable>(find.byType(AppDataTable));
    expect(table.columns, hasLength(5));
    expect(table.columns.last.sortable, isTrue);
    expect(table.rows, hasLength(10));
    final chips = tester.widgetList<AppStatusChip>(find.byType(AppStatusChip));
    expect(chips.every((c) => c.label == 'صحيح' && c.count == null), isTrue);
    expect(find.text('إجمالي 20 poi'), findsOneWidget);
    expect(
      find.textContaining('سيتم استيراد السجلات الصحيحة فقط'),
      findsOneWidget,
    );
  });

  testWidgets('a double tap on confirm imports once', (tester) async {
    final cubit = await openPreview(tester);
    // Both taps land before a frame, so only the cubit's guard stops the
    // second; the bar's loading state covers taps after it.
    await tester.tap(find.byKey(AppFormBottomBar.primaryKey));
    await tester.tap(find.byKey(AppFormBottomBar.primaryKey));
    await tester.pumpAndSettle();
    final summary = (cubit.state.step as PoiImportConfirmStep).summary;
    expect(summary.imported, 20);
    expect(find.byKey(AppFormBottomBar.primaryKey), findsNothing);
  });

  testWidgets('previous goes back to validation', (tester) async {
    final cubit = await openPreview(tester);
    await tester.tap(find.byKey(AppFormBottomBar.cancelKey));
    await tester.pumpAndSettle();
    expect(cubit.state.step, isA<PoiImportValidationStep>());
    expect(cubit.state.count(PoiRowStatus.valid), 20);
  });
}
