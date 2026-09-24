import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as clusters;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:nasam/features/tracking/presentation/tracking_page.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_controls.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_map.dart';

import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/widget_harness.dart';

/// The real repository over the dummy source — what the app resolves in dev.
TrackingRepository _dummyRepository() => fixtureTrackingRepository();

/// The screen as the router builds it: a TrackingCubit over the fixture
/// repository, provided above the page rather than created inside it.
Widget _trackingScreen() {
  final repository = _dummyRepository();
  return BlocProvider(
    create: (_) => TrackingCubit(
      GetTrackingVehiclesUseCase(repository),
      GetTrackedAssetsUseCase(repository),
    )..load(),
    child: const TrackingPage(),
  );
}

/// Unwraps a Right, failing the test loudly if the call went Left.
Future<List<TrackingVehicle>> _fleet() async =>
    (await _dummyRepository().getVehicles()).getOrElse(
      () => throw StateError('fleet unavailable'),
    );

class _MockLogout extends Mock implements LogoutUseCase {}

void main() {
  // The drawer's sign-out is resolved from the container.
  setUp(() {
    final logout = _MockLogout();
    when(logout.call).thenAnswer((_) async => const Right(unit));
    getIt.registerFactory<LogoutCubit>(() => LogoutCubit(logout));
  });
  tearDown(() => getIt.unregister<LogoutCubit>());

  test('the fixture fleet has distinct ids and consistent status counts',
      () async {
    final fleet = await _fleet();
    expect(fleet, hasLength(68));
    expect(fleet.map((v) => v.id).toSet(), hasLength(68));
    expect(
      VehicleStatus.values.fold<int>(
        0,
        (sum, s) => sum + fleet.where((v) => v.status == s).length,
      ),
      68,
    );
  });
  test(
    'bounds contain the entire fleet and handle empty and single fleets',
    () async {
      final fleet = await _fleet();
      expect(vehicleBounds([]), isNull);
      final single = vehicleBounds([fleet.first])!;
      expect(
        single.contains(LatLng(fleet.first.latitude, fleet.first.longitude)),
        true,
      );
      expect(single.northeast.latitude, greaterThan(single.southwest.latitude));
      final bounds = vehicleBounds(fleet)!;
      for (final v in fleet) {
        expect(bounds.contains(LatLng(v.latitude, v.longitude)), true);
      }
    },
  );
  test(
    'cluster focus bounds tightly frame members, including coincident vehicles',
    () async {
      final fleet = await _fleet();
      final members = fleet.take(15).toList();
      final bounds = vehicleBounds(members, minimumSpan: .0004)!;
      for (final member in members) {
        expect(
          bounds.contains(LatLng(member.latitude, member.longitude)),
          true,
        );
      }
      expect(
        bounds.contains(LatLng(fleet.last.latitude, fleet.last.longitude)),
        false,
      );
      expect(
        bounds.northeast.latitude - bounds.southwest.latitude,
        lessThan(.002),
      );
      final coincident = vehicleBounds([
        members.first,
        members.first,
      ], minimumSpan: .0004)!;
      expect(
        coincident.northeast.latitude,
        greaterThan(coincident.southwest.latitude),
      );
      expect(
        coincident.northeast.longitude,
        greaterThan(coincident.southwest.longitude),
      );
    },
  );
  test('clusters preserve all vehicles and split at street zoom', () async {
    final platform = FakeMapPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
    final fleet = await _fleet();
    final manager = clusters.ClusterManager<VehicleMapItem>(
      fleet.map(VehicleMapItem.new).toList(),
      (_) {},
      levels: trackingClusterLevels,
      stopClusteringZoom: 17,
    );
    // setMapId no longer returns a Future in this fork; prime the zoom the
    // manager reads internally via onCameraMove instead of awaiting it.
    manager.setMapId(1, withUpdate: false);
    manager.onCameraMove(
      const CameraPosition(target: LatLng(24.86, 46.4), zoom: 11),
    );
    final groups = await manager.getMarkers();
    expect(groups.length, lessThan(fleet.length));
    expect(groups.where((c) => !c.isMultiple).length, greaterThanOrEqualTo(3));
    expect(groups.fold<int>(0, (sum, c) => sum + c.count), fleet.length);
    manager.onCameraMove(
      const CameraPosition(target: LatLng(24.86, 46.4), zoom: 18),
    );
    expect(await manager.getMarkers(), hasLength(fleet.length));
  });
  testWidgets(
    'small dark screen keeps drawer and overlay controls accessible',
    (tester) async {
      GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
      await pumpInApp(
        tester,
        _trackingScreen(),
        locale: const Locale('ar'),
        dark: true,
      );
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      final menu = find.byWidgetPredicate(
        (w) => w is TrackingIconButton && w.menu,
      );
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Aya Al-Rashidi'));
      await tester.pumpAndSettle();
      expect(find.text('Aya Al-Rashidi').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'drawer animates through intermediate values opening and closing',
    (tester) async {
      GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
      await pumpInApp(
        tester,
        _trackingScreen(),
      );
      await tester.pumpAndSettle();
      final drawer = tester.widget<AdvancedDrawer>(find.byType(AdvancedDrawer));
      final animation = drawer.animationController!;
      drawer.controller!.showDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(animation.value, greaterThan(0));
      expect(animation.value, lessThan(1));
      expect(
        tester
            .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
            .animationController,
        same(animation),
      );
      await tester.pumpAndSettle();
      expect(animation.value, 1);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(animation.value, greaterThan(0));
      expect(animation.value, lessThan(1));
      await tester.pumpAndSettle();
      expect(animation.value, 0);
      expect(tester.takeException(), isNull);
    },
  );
  for (final locale in ['ar', 'en']) {
    testWidgets(
      '$locale tracking drawer opens and closes; tools stay inactive',
      (tester) async {
        GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
        await pumpInApp(
          tester,
          _trackingScreen(),
          locale: Locale(locale),
        );
        await tester.pumpAndSettle();
        final buttons = tester.widgetList<TrackingIconButton>(
          find.byType(TrackingIconButton),
        );
        // menu, layers, zoom in, zoom out.
        expect(buttons.where((b) => b.onTap != null), hasLength(4));
        final menu = find.byWidgetPredicate(
          (w) => w is TrackingIconButton && w.menu,
        );
        await tester.tap(menu);
        await tester.pumpAndSettle();
        expect(find.text('Aya Al-Rashidi').hitTestable(), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(menu.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
