import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_editor_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_details_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';

import 'fake_map_platform.dart';
import 'fixture_bundle.dart';
import 'widget_harness.dart';

/// Which POI form screen to pump.
enum PoiFormScreen { create, edit, view }

/// Pumps Create, Edit or View over the fixture points (Edit and View show
/// `poi-1`) on [size], at [scale], and returns the editor cubit.
Future<PoiEditorCubit> pumpPoiFormScreen(
  WidgetTester tester,
  PoiFormScreen screen, {
  Size size = const Size(402, 874),
  String language = 'ar',
  bool dark = false,
  double scale = 1,
}) async {
  GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
  final repository = PoiRepositoryImpl(
    PoiFixtureDataSource(bundle: DiskAssetBundle()),
  );
  final cubit = PoiEditorCubit(
    GetPointOfInterestUseCase(repository),
    SavePointOfInterestUseCase(repository),
    DeletePointOfInterestUseCase(repository),
  );
  addTearDown(cubit.close);
  if (screen != PoiFormScreen.create) await cubit.load('poi-1');
  await pumpInApp(
    tester,
    BlocProvider.value(
      value: cubit,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: switch (screen) {
            PoiFormScreen.create => const PoiEditorPage(),
            PoiFormScreen.edit => const PoiEditorPage(pointId: 'poi-1'),
            PoiFormScreen.view => const PoiDetailsPage(pointId: 'poi-1'),
          },
        ),
      ),
    ),
    locale: Locale(language),
    dark: dark,
  );
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
  return cubit;
}
