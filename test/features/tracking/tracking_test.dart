import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as clusters;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:dartz/dartz.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_dummy_datasource.dart';
import 'package:nasam/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset_details.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_playback_segment.dart';
import 'package:nasam/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:nasam/features/tracking/presentation/tracking_page.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_controls.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_map.dart';

import '../../helpers/widget_harness.dart';

class _MapPlatform extends GoogleMapsFlutterPlatform {
  double zoom = 11;
  @override
  Future<double> getZoomLevel({required int mapId}) async => zoom;
  @override
  Future<LatLngBounds> getVisibleRegion({required int mapId}) async =>
      LatLngBounds(
        southwest: const LatLng(24.7, 46.2),
        northeast: const LatLng(25, 46.6),
      );

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const ColoredBox(color: Color(0xFFF3EFE5));
}

/// Every call fails. The repository returns Either now, so a failure is a
/// value rather than a thrown error — which is the point: the cubit cannot
/// forget to handle it.
class _FailingRepository implements TrackingRepository {
  static const _failure = ServerFailure(message: 'Unavailable');

  @override
  Future<Either<Failure, List<TrackingVehicle>>> getVehicles() async =>
      const Left(_failure);

  @override
  Future<Either<Failure, List<TrackedAsset>>> getTrackedAssets() async =>
      const Left(_failure);

  @override
  Future<Either<Failure, TrackedAssetDetails>> getAssetDetails(String id) async =>
      const Left(_failure);

  @override
  Future<Either<Failure, List<TrackedAssetNotification>>> getAssetNotifications(
    String id,
  ) async => const Left(_failure);

  @override
  Future<Either<Failure, List<TrackingPlaybackSegment>>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async => const Left(_failure);
}

/// The real repository over the dummy source — what the app resolves in dev.
TrackingRepository _dummyRepository() =>
    const TrackingRepositoryImpl(TrackingDummyDataSource());

/// Unwraps a Right, failing the test loudly if the call went Left.
Future<List<TrackingVehicle>> _fleet() async =>
    (await _dummyRepository().getVehicles()).getOrElse(
      () => throw StateError('fleet unavailable'),
    );

void main() {
  test('dummy fleet has distinct IDs and consistent status counts', () async {
    final cubit = TrackingCubit(_dummyRepository());
    await cubit.load();
    expect(cubit.state.loading, false);
    expect(cubit.state.vehicles, hasLength(68));
    expect(cubit.state.vehicles.map((v) => v.id).toSet(), hasLength(68));
    expect(
      VehicleStatus.values.fold<int>(0, (sum, s) => sum + cubit.state.count(s)),
      68,
    );
    await cubit.close();
  });
  test('failed repository produces a recoverable failure state', () async {
    final cubit = TrackingCubit(_FailingRepository());
    await cubit.load();
    expect(cubit.state.failed, true);
    expect(cubit.state.loading, false);
    await cubit.close();
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
    final platform = _MapPlatform();
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
      GoogleMapsFlutterPlatform.instance = _MapPlatform();
      await pumpInApp(
        tester,
        TrackingPage(repository: _dummyRepository()),
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
      GoogleMapsFlutterPlatform.instance = _MapPlatform();
      await pumpInApp(
        tester,
        TrackingPage(repository: _dummyRepository()),
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
        GoogleMapsFlutterPlatform.instance = _MapPlatform();
        await pumpInApp(
          tester,
          TrackingPage(repository: _dummyRepository()),
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
