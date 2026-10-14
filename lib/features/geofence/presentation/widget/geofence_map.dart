import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoFenceMapController {
  _GeoFenceMapState? _state;
  Future<void> zoomIn() async => _state?._move(CameraUpdate.zoomIn());
  Future<void> zoomOut() async => _state?._move(CameraUpdate.zoomOut());
  // Future<void> focus(PointOfInterest point) async => _state?._move(
  //   CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 16),
  // );
}
class GeofenceMap extends StatefulWidget{
  final GeoFenceMapController controller;
  final double bottomInset;
  final String? selectedId;
  final MapType mapType;
  const GeofenceMap({super.key, required this.controller, required this.bottomInset, this.selectedId, required this.mapType});

  @override
  State<GeofenceMap> createState() => _GeoFenceMapState();
}
class _GeoFenceMapState extends  State<GeofenceMap> {
  GoogleMapController? _map;
  @override
  void initState() {
    // TODO: implement initState
    widget.controller._state = this;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
     return Container();
  }
  Future<void> _move(CameraUpdate update) async {}
}