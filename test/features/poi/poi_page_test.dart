import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_page.dart';

import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';
import '../../helpers/widget_harness.dart';

void main() {
  Future<PoiCubit> pump(
    WidgetTester tester, {
    Size size = const Size(402, 874),
    bool dark = false,
    String language = 'en',
    double scale = 1,
  }) async {
    GoogleMapsFlutterPlatform.instance = FakeMapPlatform(createsMap: true);
    final repository = PoiRepositoryImpl(
      PoiFixtureDataSource(bundle: DiskAssetBundle()),
    );
    final cubit = PoiCubit(
      GetPointsOfInterestUseCase(repository),
      FakePoiFiles(),
      DeletePointOfInterestUseCase(repository),
      WatchPoiChangesUseCase(repository),
    );
    await cubit.load();
    addTearDown(cubit.close);
    await pumpInApp(
      tester,
      BlocProvider.value(
        value: cubit,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: PoiPage(openDrawer: () {}),
          ),
        ),
      ),
      dark: dark,
      locale: Locale(language),
    );
    tester.view.physicalSize = size;
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets(
    'Show expands, search filters markers and list, details focus the map',
    (tester) async {
      final cubit = await pump(tester);
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).markers.length,
        4,
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Hide'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Manhole');
      await tester.pumpAndSettle();
      expect(cubit.state.visiblePoints.single.name, 'Manhole');
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).markers.length,
        1,
      );
      await tester.tap(find.byTooltip('Point of interest actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show on map'));
      await tester.pumpAndSettle();
      expect(cubit.state.selectedId, 'poi-2');
      await tester.tap(find.bySemanticsLabel('Layers'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).mapType,
        MapType.hybrid,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('POI Arabic landing visual baseline', (tester) async {
    await pump(tester, language: 'ar');
    await expectLater(
      find.byType(PoiPage),
      matchesGoldenFile('goldens/poi_landing_ar.png'),
    );
    await tester.tap(find.text('عرض'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PoiPage),
      matchesGoldenFile('goldens/poi_expanded_ar.png'),
    );
  });
  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(800, 1024),
    const Size(844, 390),
  ]) {
    for (final language in ['ar', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('responsive $size $language dark=$dark enlarged text', (
          tester,
        ) async {
          await pump(
            tester,
            size: size,
            language: language,
            dark: dark,
            scale: 1.5,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(language == 'ar' ? 'عرض' : 'Show'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.enterText(find.byType(TextField), 'nothing');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
