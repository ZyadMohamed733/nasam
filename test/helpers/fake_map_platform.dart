import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Stands in for the Google Maps plugin, which has no implementation under
/// `flutter test`: a flat map-coloured box, a fixed zoom and a fixed view of
/// Riyadh. Install it with `GoogleMapsFlutterPlatform.instance = ...` before
/// pumping anything that builds a map.
///
/// By default the map is never "created", so `onMapCreated` does not fire —
/// enough for layout tests. Pass [createsMap] to go further: the platform
/// view reports itself created after the first frame, camera moves and
/// marker updates are recorded, and [failBoundsFit] makes a bounds fit throw
/// the way the native SDK does before the map has a size.
class FakeMapPlatform extends GoogleMapsFlutterPlatform {
  FakeMapPlatform({this.createsMap = false, this.failBoundsFit = false});

  final bool createsMap;
  bool failBoundsFit;
  double zoom = 11;

  final List<CameraUpdate> cameraMoves = [];
  final Map<MarkerId, Marker> markers = {};
  final Set<int> disposedMaps = {};
  final Set<int> _created = {};

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
  }) {
    if (createsMap && _created.add(creationId)) {
      for (final marker in mapObjects.markers) {
        markers[marker.markerId] = marker;
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => onPlatformViewCreated(creationId),
      );
    }
    return const ColoredBox(color: Color(0xFFF3EFE5));
  }

  @override
  Future<void> init(int mapId) async {}

  @override
  void dispose({required int mapId}) {
    if (!disposedMaps.add(mapId)) {
      throw StateError('map $mapId disposed twice');
    }
  }

  Future<void> _camera(CameraUpdate update) async {
    if (failBoundsFit &&
        update.updateType == CameraUpdateType.newLatLngBounds) {
      throw PlatformException(
        code: 'error',
        message:
            'Map size can\'t be 0. Most likely, layout has not yet '
            'occurred for the map view.',
      );
    }
    cameraMoves.add(update);
  }

  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate, {required int mapId}) =>
      _camera(cameraUpdate);

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate, {required int mapId}) =>
      _camera(cameraUpdate);

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {
    for (final id in markerUpdates.markerIdsToRemove) {
      markers.remove(id);
    }
    for (final marker in [
      ...markerUpdates.markersToAdd,
      ...markerUpdates.markersToChange,
    ]) {
      markers[marker.markerId] = marker;
    }
  }

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    required int mapId,
  }) async {}

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {}

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates groundOverlayUpdates, {
    required int mapId,
  }) async {}

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PointOfInterestTapEvent> onPointOfInterestTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MapTapEvent> onTap({required int mapId}) => const Stream.empty();
  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({required int mapId}) =>
      const Stream.empty();
}
