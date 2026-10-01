import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/domain/entities/poi_limits.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/features/poi/presentation/widgets/import/poi_import_file_row.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_file_drop_zone.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_stepper.dart';

import '../../helpers/poi_import_screen.dart';

void main() {
  bool validateEnabled(WidgetTester tester) =>
      tester
          .widget<AppButton>(find.byKey(AppFormBottomBar.primaryKey))
          .onPressed !=
      null;

  testWidgets('shows the limits from PoiLimits, not the design\'s sample', (
    tester,
  ) async {
    await pumpPoiImportPage(tester);
    expect(find.byType(AppStepper), findsOneWidget);
    expect(find.text(PoiLimits.fileExtension), findsOneWidget);
    expect(find.text('${PoiLimits.maxFileMegabytes}MB'), findsOneWidget);
    expect(find.text('${PoiLimits.maxRecords}'), findsOneWidget);
    // The drop zone's hint states the same format and size.
    final zone = tester.widget<AppFileDropZone>(find.byType(AppFileDropZone));
    expect(zone.hint, contains(PoiLimits.fileExtension));
    expect(zone.hint, contains('${PoiLimits.maxFileMegabytes}'));
    expect(zone.hint, isNot(contains('PDF')));
  });

  testWidgets('validate stays disabled until a file is picked; the file row '
      'shows it and removing it disables validate again', (tester) async {
    final (cubit, _) = await pumpPoiImportPage(tester);
    expect(validateEnabled(tester), isFalse);
    expect(find.byType(PoiImportFileRow), findsNothing);

    await tester.tap(find.text('استعراض الملفات'));
    await tester.pumpAndSettle();
    expect(cubit.state.file?.name, 'POIs.xlsx');
    expect(find.text('POIs.xlsx'), findsOneWidget);
    expect(find.text('12.0 KB'), findsOneWidget);
    expect(validateEnabled(tester), isTrue);

    await tester.tap(find.byKey(PoiImportFileRow.removeKey));
    await tester.pumpAndSettle();
    expect(cubit.state.file, isNull);
    expect(find.byType(PoiImportFileRow), findsNothing);
    expect(validateEnabled(tester), isFalse);
  });

  testWidgets('validate moves to step 2', (tester) async {
    final (cubit, _) = await pumpPoiImportPage(tester);
    await cubit.pick();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AppFormBottomBar.primaryKey));
    await tester.pumpAndSettle();
    expect(cubit.state.step, isA<PoiImportValidationStep>());
  });

  test('file sizes read in KB or MB', () {
    expect(PoiImportFileRow.size(0), '');
    expect(PoiImportFileRow.size(2048), '2.0 KB');
    expect(PoiImportFileRow.size(3 * 1024 * 1024), '3.0 MB');
  });
}
