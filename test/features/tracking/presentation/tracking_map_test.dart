import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_map.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_marker_factory.dart';

import '../../../helpers/fake_map_platform.dart';
import '../../../helpers/fixture_bundle.dart';
import '../../../helpers/widget_harness.dart';

/// Hands out stock pins without drawing, and can fail on demand; the real
/// drawing is covered in tracking_marker_factory_test.
class _StubFactory extends TrackingMarkerFactory {
  _StubFactory() : super(pixelRatio: 1);

  bool failVehicles = false;

  @override
  Future<BitmapDescriptor> vehicle({
    required String label,
    required Color color,
    required double heading,
    required TextDirection direction,
  }) async {
    if (failVehicles) throw const MarkerDrawException('stub');
    return BitmapDescriptor.defaultMarker;
  }

  @override
  Future<BitmapDescriptor> cluster(int count, Color color) async =>
      BitmapDescriptor.defaultMarker;
}

void main() {
  late FakeMapPlatform platform;
  late List<TrackingVehicle> fleet;
  late List<_StubFactory> built;

  setUp(() async {
    platform = FakeMapPlatform(createsMap: true);
    GoogleMapsFlutterPlatform.instance = platform;
    fleet = (await fixtureTrackingRepository().getVehicles()).getOrElse(
      () => throw StateError('no fleet'),
    );
    built = [];
  });

  Widget map({TrackingMapController? controller}) => SizedBox(
    width: 402,
    height: 700,
    child: TrackingMap(
      vehicles: fleet,
      bottomInset: 0,
      controller: controller,
      markerFactoryBuilder: (_) {
        final factory = _StubFactory();
        built.add(factory);
        return factory;
      },
    ),
  );

  Set<Marker> shownMarkers(WidgetTester tester) =>
      tester.widget<GoogleMap>(find.byType(GoogleMap)).markers;

  testWidgets('markers still appear when fitting the fleet fails', (
    tester,
  ) async {
    platform.failBoundsFit = true;

    await pumpInApp(tester, map());
    await tester.pumpAndSettle();

    expect(shownMarkers(tester), isNotEmpty);
    expect(find.text('Something went wrong'), findsNothing);
    // It fell back to centring on the fleet at the fallback zoom.
    final fallback = platform.cameraMoves
        .whereType<CameraUpdateNewLatLngZoom>()
        .single;
    expect(fallback.zoom, TrackingMapLayout.fallbackZoom);
    expect(fallback.latLng, boundsCenter(vehicleBounds(fleet)!));
  });

  testWidgets('a fit failure on a fleet update is contained too', (
    tester,
  ) async {
    await pumpInApp(tester, map());
    await tester.pumpAndSettle();
    platform.failBoundsFit = true;

    fleet = fleet.take(10).toList();
    await pumpInApp(tester, map());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(shownMarkers(tester), isNotEmpty);
  });

  testWidgets('a vehicle whose bitmap fails still gets a pin', (tester) async {
    await pumpInApp(tester, map());
    built.single.failVehicles = true;
    await tester.pumpAndSettle();

    expect(shownMarkers(tester), isNotEmpty);
    expect(
      shownMarkers(
        tester,
      ).every((m) => m.icon == BitmapDescriptor.defaultMarker),
      isTrue,
    );
  });

  group('the marker factory is rebuilt only when the style changes', () {
    Future<void> pumpWith(
      WidgetTester tester, {
      EdgeInsets padding = EdgeInsets.zero,
      ColorScheme? scheme,
    }) async {
      await pumpInApp(
        tester,
        Builder(
          builder: (context) {
            Widget child = MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: padding),
              child: map(),
            );
            if (scheme != null) {
              child = Theme(
                data: Theme.of(context).copyWith(colorScheme: scheme),
                child: child,
              );
            }
            return child;
          },
        ),
      );
      await tester.pumpAndSettle();
    }

    // A keyboard, a status bar or a notch change moves padding; redrawing
    // every bitmap for that is wasted work.
    testWidgets('not for a MediaQuery padding change', (tester) async {
      await pumpWith(tester);
      await pumpWith(tester, padding: const EdgeInsets.only(top: 47));
      await pumpWith(tester, padding: const EdgeInsets.only(bottom: 300));

      expect(built, hasLength(1));
    });

    testWidgets('but for a colour scheme change', (tester) async {
      await pumpWith(tester);
      await pumpWith(
        tester,
        scheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      );

      expect(built, hasLength(2));
    });
  });

  group('controller', () {
    testWidgets('zooms the live map', (tester) async {
      final controller = TrackingMapController();
      await pumpInApp(tester, map(controller: controller));
      await tester.pumpAndSettle();
      platform.cameraMoves.clear();

      await controller.zoomIn();
      await controller.zoomOut();

      expect(platform.cameraMoves.map((u) => u.updateType), [
        CameraUpdateType.zoomIn,
        CameraUpdateType.zoomOut,
      ]);
    });

    testWidgets('after the map is disposed, zoom is a no-op', (tester) async {
      final controller = TrackingMapController();
      await pumpInApp(tester, map(controller: controller));
      await tester.pumpAndSettle();

      await pumpInApp(tester, const SizedBox());
      await tester.pumpAndSettle();
      platform.cameraMoves.clear();

      expect(controller.isAttached, isFalse);
      await controller.zoomIn();
      await controller.zoomOut();
      expect(platform.cameraMoves, isEmpty);
      expect(tester.takeException(), isNull);
      // GoogleMap disposed its controller, once; the fake throws on a second.
      expect(platform.disposedMaps, hasLength(1));
    });
  });
}
