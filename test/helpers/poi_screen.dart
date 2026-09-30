import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_page.dart';

import 'fake_map_platform.dart';
import 'fixture_bundle.dart';
import 'poi_files.dart';
import 'widget_harness.dart';

/// Pumps the POI home screen over the fixture points, collapsed, on [size]
/// (the design frame by default), and returns its cubit.
Future<PoiCubit> pumpPoiPage(
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
