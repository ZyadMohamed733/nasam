import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/features/play_back/data/datasources/playback_fixture_datasource.dart';
import 'package:nasam/features/play_back/data/repositories/playback_repository_impl.dart';
import 'package:nasam/features/play_back/domain/usecases/get_playback_route_usecase.dart';
import 'package:nasam/features/play_back/presentation/cubit/playback_map_cubit.dart';
import 'package:nasam/features/play_back/presentation/pages/playback_map_page.dart';
import 'package:nasam/features/play_back/presentation/utils/playback_range.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_details_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_asset_notifications_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_asset_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/asset_details_cubit.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracked_asset_cubit.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_asset_details_page.dart';

import 'fake_map_platform.dart';
import 'fixture_bundle.dart';
import 'widget_harness.dart';

/// An asset the fixtures have details, alerts and playback for.
const fixtureAssetId = 'AST-0017';

class MockRouter extends Mock implements GoRouter {}

/// A router that records navigation instead of doing it.
({MockRouter router, List<String> log}) recordingRouter() {
  final router = MockRouter();
  final log = <String>[];
  when(
    () => router.push<Object?>(any(), extra: any(named: 'extra')),
  ).thenAnswer((i) async {
    log.add('push ${i.positionalArguments.first}');
    return null;
  });
  when(() => router.pop<Object?>(any())).thenAnswer((_) => log.add('pop'));
  when(router.canPop).thenReturn(true);
  return (router: router, log: log);
}

/// The details screen as the route builds it, over the fixtures.
Widget assetDetailsScreen([String id = fixtureAssetId]) {
  final repository = fixtureTrackingRepository();
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            TrackedAssetCubit(GetTrackedAssetUseCase(repository))..load(id),
      ),
      BlocProvider(
        create: (_) => AssetDetailsCubit(
          GetAssetDetailsUseCase(repository),
          GetAssetNotificationsUseCase(repository),
        )..load(id),
      ),
    ],
    child: TrackingAssetDetailsPage(assetId: id),
  );
}

/// The playback screen as the route builds it, over the fixtures.
Widget assetPlaybackScreen([String id = fixtureAssetId, PlaybackRange? range]) {
  GoogleMapsFlutterPlatform.instance = FakeMapPlatform(createsMap: true);
  final repository = fixtureTrackingRepository();
  final playbackRepository = PlaybackRepositoryImpl(
    PlaybackFixtureDataSource(
      bundle: DiskAssetBundle(),
      latency: Duration.zero,
    ),
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            TrackedAssetCubit(GetTrackedAssetUseCase(repository))..load(id),
      ),
      BlocProvider(
        create: (_) =>
            PlaybackMapCubit(GetPlaybackRouteUseCase(playbackRepository)),
      ),
    ],
    child: PlaybackMapPage(
      assetId: id,
      initialRange: range ?? PlaybackRange.today(),
    ),
  );
}

/// Pumps [screen] in the app shell, under [router], at [size] and
/// [textScale].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  GoRouter? router,
  Size size = const Size(402, 874),
  double textScale = 1,
  Locale locale = const Locale('en'),
  bool dark = false,
}) async {
  registerFallbackValue(Uri());
  final routed = router == null
      ? screen
      : InheritedGoRouter(goRouter: router, child: screen);
  await pumpInApp(
    tester,
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: routed,
      ),
    ),
    locale: locale,
    dark: dark,
  );
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
}
