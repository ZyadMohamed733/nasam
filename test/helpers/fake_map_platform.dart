import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Stands in for the Google Maps plugin, which has no implementation under
/// `flutter test`: a flat map-coloured box, a fixed zoom and a fixed view of
/// Riyadh. Install it with `GoogleMapsFlutterPlatform.instance = ...` before
/// pumping anything that builds a map.
class FakeMapPlatform extends GoogleMapsFlutterPlatform {
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
