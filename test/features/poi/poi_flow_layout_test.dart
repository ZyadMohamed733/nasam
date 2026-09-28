import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_editor_cubit.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_details_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_import_page.dart';

import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';
import '../../helpers/widget_harness.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(800, 1024),
    const Size(844, 390),
  ]) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('POI forms/import $size $language dark=$dark large text', (
          tester,
        ) async {
          GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
          final repository = PoiRepositoryImpl(
            PoiFixtureDataSource(bundle: DiskAssetBundle()),
          );
          final editor = PoiEditorCubit(
            GetPointOfInterestUseCase(repository),
            SavePointOfInterestUseCase(repository),
            DeletePointOfInterestUseCase(repository),
          );
          final importer = PoiImportCubit(
            FakePoiFiles()
              ..selected = const PickedPoiWorkbook('sample.xlsx', [
                ['name', 'latitude', 'longitude', 'icon', 'notes'],
                ['اسم نقطة اهتمام طويلة جدا', '24', '46', 'fuel', ''],
                ['Invalid', '91', '46', 'fuel', ''],
              ]),
            GetPointsOfInterestUseCase(repository),
            ImportPointsOfInterestUseCase(repository),
          );
          addTearDown(editor.close);
          addTearDown(importer.close);
          Future<void> show(Widget child) async {
            await pumpInApp(
              tester,
              MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: editor),
                  BlocProvider.value(value: importer),
                ],
                child: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.5)),
                    child: child,
                  ),
                ),
              ),
              locale: Locale(language),
              dark: dark,
            );
            tester.view.physicalSize = size;
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await show(const PoiEditorPage());
          await tester.ensureVisible(find.byType(TextField).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await editor.load('poi-1');
          await show(const PoiDetailsPage(pointId: 'poi-1'));
          await show(const PoiImportPage());
          await importer.pick();
          await importer.validate();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          importer.preview();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await importer.confirm();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('Arabic create and upload visual references', (tester) async {
    GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
    final repository = PoiRepositoryImpl(
      PoiFixtureDataSource(bundle: DiskAssetBundle()),
    );
    final editor = PoiEditorCubit(
      GetPointOfInterestUseCase(repository),
      SavePointOfInterestUseCase(repository),
      DeletePointOfInterestUseCase(repository),
    );
    addTearDown(editor.close);
    await pumpInApp(
      tester,
      BlocProvider.value(value: editor, child: const PoiEditorPage()),
      locale: const Locale('ar'),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PoiEditorPage),
      matchesGoldenFile('goldens/poi_create_ar.png'),
    );
    final importer = PoiImportCubit(
      FakePoiFiles(),
      GetPointsOfInterestUseCase(repository),
      ImportPointsOfInterestUseCase(repository),
    );
    addTearDown(importer.close);
    await pumpInApp(
      tester,
      BlocProvider.value(value: importer, child: const PoiImportPage()),
      locale: const Locale('ar'),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PoiImportPage),
      matchesGoldenFile('goldens/poi_upload_ar.png'),
    );
  });
}
