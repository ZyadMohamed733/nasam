import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/entities/poi_draft.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_editor_cubit.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';

void main() {
  late PoiRepositoryImpl repository;
  setUp(
    () => repository = PoiRepositoryImpl(
      PoiFixtureDataSource(bundle: DiskAssetBundle()),
    ),
  );
  test(
    'create/edit/delete round trip, duplicate save and missing IDs',
    () async {
      final editor = PoiEditorCubit(
        GetPointOfInterestUseCase(repository),
        SavePointOfInterestUseCase(repository),
        DeletePointOfInterestUseCase(repository),
      );
      const draft = PoiDraft(
        name: ' New station ',
        latitude: 24.8,
        longitude: 46.4,
        icon: PoiIcon.fuel,
        notes: 'notes',
      );
      await Future.wait([editor.save(draft), editor.save(draft)]);
      expect(editor.state.status, PoiEditorStatus.saved);
      final id = editor.state.point!.id;
      expect(editor.state.point!.name, 'New station');
      expect((await repository.getPoints()).getOrElse(() => []).length, 5);
      await editor.load(id);
      await editor.save(
        const PoiDraft(
          name: 'Edited',
          latitude: 25,
          longitude: 47,
          icon: PoiIcon.hospital,
        ),
        id: id,
      );
      expect(editor.state.point!.icon, PoiIcon.hospital);
      await editor.load(id);
      await editor.delete(id);
      expect(editor.state.status, PoiEditorStatus.deleted);
      expect((await repository.getPoint(id)).isLeft(), true);
      expect((await repository.save(draft, id: 'unknown')).isLeft(), true);
      await editor.close();
    },
  );
  test(
    'invalid batch cannot partially mutate data, duplicate import is skipped',
    () async {
      const valid = PoiDraft(name: 'Unique', latitude: 20, longitude: 40);
      const invalid = PoiDraft(name: '', latitude: 91, longitude: 40);
      expect((await repository.importPoints([valid, invalid])).isLeft(), true);
      expect((await repository.getPoints()).getOrElse(() => []).length, 4);
      expect(
        (await repository.importPoints([valid, valid])).getOrElse(() => -1),
        1,
      );
      expect((await repository.importPoints([valid])).getOrElse(() => -1), 0);
    },
  );
  test(
    'import cancellation, retry, validation, previous, preview and confirm once',
    () async {
      final files = FakePoiFiles();
      final cubit = PoiImportCubit(
        files,
        GetPointsOfInterestUseCase(repository),
        ImportPointsOfInterestUseCase(repository),
      );
      await cubit.validate();
      await cubit.confirm();
      expect(cubit.state.step, 0);
      await cubit.pick();
      expect(cubit.state.fileName, isNull);
      files.fail = true;
      await cubit.pick();
      expect(cubit.state.error, true);
      files.fail = false;
      files.selected = const PickedPoiWorkbook('points.xlsx', [
        ['name', 'latitude', 'longitude', 'icon', 'notes'],
        ['New', '24', '46', 'fuel', ''],
        ['Bad', '999', '46', 'fuel', ''],
        ['New', '24', '46', 'fuel', ''],
      ]);
      await cubit.pick();
      await cubit.validate();
      expect(cubit.state.step, 1);
      expect(cubit.state.valid.length, 1);
      cubit.preview();
      expect(cubit.state.step, 2);
      cubit.previous();
      expect(cubit.state.step, 1);
      cubit.preview();
      await Future.wait([cubit.confirm(), cubit.confirm()]);
      expect(cubit.state.step, 3);
      expect(cubit.state.imported, 1);
      expect((await repository.getPoints()).getOrElse(() => []).length, 5);
      cubit.previous();
      expect(cubit.state.step, 3);
      await cubit.close();
    },
  );
}
