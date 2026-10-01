import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/entities/poi_import_row.dart';
import 'package:nasam/features/poi/domain/entities/poi_validation.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';

import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';
import '../../helpers/poi_import_screen.dart';

/// The filter, page and counts are derived in the state, from the design's
/// 24-row sample: 20 valid, 3 invalid, 1 duplicate.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PoiImportCubit build() {
    final repository = PoiRepositoryImpl(
      PoiFixtureDataSource(bundle: DiskAssetBundle()),
    );
    return PoiImportCubit(
      FakePoiFiles()..selected = samplePoiWorkbook(),
      GetPointsOfInterestUseCase(repository),
      ImportPointsOfInterestUseCase(repository),
    );
  }

  Future<void> validated(PoiImportCubit cubit) async {
    await cubit.pick();
    await cubit.validate();
  }

  blocTest<PoiImportCubit, PoiImportState>(
    'counts every status, and keeps each invalid row\'s reasons',
    build: build,
    act: validated,
    verify: (cubit) {
      final state = cubit.state;
      expect(state.step, isA<PoiImportValidationStep>());
      expect(
        [
          for (final s in [null, ...PoiRowStatus.values]) state.count(s),
        ],
        [24, 20, 3, 1],
      );
      expect(
        [
          for (final row in state.rows)
            if (row.status == PoiRowStatus.invalid) row.issues,
        ],
        [
          [PoiIssue.latitudeInvalid],
          [PoiIssue.nameRequired],
          [PoiIssue.longitudeInvalid, PoiIssue.iconUnknown],
        ],
      );
    },
  );

  blocTest<PoiImportCubit, PoiImportState>(
    'pages ten rows at a time and clamps the page',
    build: build,
    act: (cubit) async {
      await validated(cubit);
      expect(cubit.state.pageCount, 3);
      expect(cubit.state.pageRows.length, 10);
      cubit.goToPage(2);
      expect(cubit.state.pageRows.length, 4);
      cubit.goToPage(9);
    },
    verify: (cubit) => expect(cubit.state.page, 2),
  );

  blocTest<PoiImportCubit, PoiImportState>(
    'a filter narrows the rows and goes back to the first page',
    build: build,
    act: (cubit) async {
      await validated(cubit);
      cubit.goToPage(1);
      cubit.filter(PoiRowStatus.invalid);
      expect(cubit.state.page, 0);
      expect(cubit.state.visibleRows.length, 3);
      expect(cubit.state.pageCount, 1);
      cubit.filter(null);
    },
    verify: (cubit) {
      expect(cubit.state.filter, isNull);
      expect(cubit.state.visibleRows.length, 24);
    },
  );

  blocTest<PoiImportCubit, PoiImportState>(
    'preview lists the valid rows only, whatever the validation filter',
    build: build,
    act: (cubit) async {
      await validated(cubit);
      cubit.filter(PoiRowStatus.duplicate);
      cubit.preview();
      cubit.filter(PoiRowStatus.invalid);
    },
    verify: (cubit) {
      final state = cubit.state;
      expect(state.step, isA<PoiImportPreviewStep>());
      expect(state.filter, isNull);
      expect(state.visibleRows.length, 20);
      expect(state.pageCount, 2);
      expect(
        state.visibleRows.every((r) => r.status == PoiRowStatus.valid),
        isTrue,
      );
    },
  );

  blocTest<PoiImportCubit, PoiImportState>(
    'confirm reports the real import: total, imported, failed, duplicates',
    build: build,
    act: (cubit) async {
      await validated(cubit);
      cubit.preview();
      await Future.wait([cubit.confirm(), cubit.confirm()]);
    },
    verify: (cubit) {
      final step = cubit.state.step as PoiImportConfirmStep;
      final s = step.summary;
      expect((s.total, s.imported, s.failed, s.duplicates), (24, 20, 3, 1));
    },
  );

  blocTest<PoiImportCubit, PoiImportState>(
    'clearing the file goes back to an empty upload',
    build: build,
    act: (cubit) async {
      await cubit.pick();
      cubit.clearFile();
      await cubit.validate();
    },
    verify: (cubit) {
      expect(cubit.state.file, isNull);
      expect(cubit.state.step, isA<PoiImportUploadStep>());
    },
  );
}
