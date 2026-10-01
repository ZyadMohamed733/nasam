import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/data/repositories/poi_repository_impl.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';
import 'package:nasam/features/poi/domain/usecases/get_points_of_interest_usecase.dart';
import 'package:nasam/features/poi/domain/usecases/poi_operations.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_import_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_import_page.dart';

import 'fixture_bundle.dart';
import 'poi_files.dart';
import 'widget_harness.dart';

/// The design's sample workbook (`561:13807`): 24 rows — 20 valid, 3
/// invalid, 1 duplicate of the first.
PickedPoiWorkbook samplePoiWorkbook() => PickedPoiWorkbook('POIs.xlsx', [
  ['name', 'latitude', 'longitude', 'icon', 'notes'],
  for (var i = 0; i < 20; i++)
    ['المستودع الرئيسي $i', '30.0626', '${31.2 + i / 100}', 'fuel', ''],
  ['المستودع الرئيسي', '91', '31.2', 'fuel', ''],
  ['', '30.0626', '31.5', 'hospital', ''],
  ['Gps', '30.0626', '200', 'gps', ''],
  ['المستودع الرئيسي 0', '30.0626', '31.2', 'fuel', ''],
], size: 12 * 1024);

/// Pumps the bulk upload on [size] over the fixture points, and returns its
/// cubit and the fake file picker (holding [samplePoiWorkbook]).
Future<(PoiImportCubit, FakePoiFiles)> pumpPoiImportPage(
  WidgetTester tester, {
  Size size = const Size(402, 874),
  String language = 'ar',
  bool dark = false,
  double scale = 1,
}) async {
  final repository = PoiRepositoryImpl(
    PoiFixtureDataSource(bundle: DiskAssetBundle()),
  );
  final files = FakePoiFiles()..selected = samplePoiWorkbook();
  final cubit = PoiImportCubit(
    files,
    GetPointsOfInterestUseCase(repository),
    ImportPointsOfInterestUseCase(repository),
  );
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
          child: const PoiImportPage(),
        ),
      ),
    ),
    locale: Locale(language),
    dark: dark,
  );
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
  return (cubit, files);
}
