import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/errors/error_reporter.dart';
import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/point_of_interest.dart';
import 'poi_icon.dart';

class PoiMapController {
  _PoiMapState? _state;
  Future<void> zoomIn() async => _state?._move(CameraUpdate.zoomIn());
  Future<void> zoomOut() async => _state?._move(CameraUpdate.zoomOut());
  Future<void> focus(PointOfInterest point) async => _state?._move(
    CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 16),
  );
}

/// POI uses its own geographic data; shared controls do not couple it to vehicles.
class PoiMap extends StatefulWidget {
  const PoiMap({
    super.key,
    required this.points,
    required this.controller,
    required this.onSelect,
    required this.bottomInset,
    this.selectedId,
    this.mapType = MapType.normal,
  });
  final List<PointOfInterest> points;
  final PoiMapController controller;
  final ValueChanged<PointOfInterest> onSelect;
  final double bottomInset;
  final String? selectedId;
  final MapType mapType;
  @override
  State<PoiMap> createState() => _PoiMapState();
}

class _PoiMapState extends State<PoiMap> {
  GoogleMapController? _map;
  final _icons = <PoiIcon, BitmapDescriptor>{};
  Color? _color;
  double? _ratio;
  int _generation = 0;
  bool _fitted = false;
  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final color = Theme.of(context).colorScheme.primary;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    if (_color != color || _ratio != ratio) {
      _color = color;
      _ratio = ratio;
      _renderIcon(color, ratio);
    }
  }

  Future<void> _renderIcon(Color color, double ratio) async {
    final generation = ++_generation;
    try {
      for (final icon in PoiIcon.values) {
        final svg = await rootBundle.loadString(
          icon == PoiIcon.fuel
              ? AppAssets.poiFuelMarker
              : PoiIconStyle.asset(icon),
        );
        final picture = await vg.loadPicture(SvgStringLoader(svg), null);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..scale(ratio);
        canvas.drawCircle(
          const Offset(20, 20),
          19,
          Paint()..color = color.withValues(alpha: .18),
        );
        canvas.drawCircle(
          const Offset(20, 20),
          19,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas
          ..save()
          ..translate(8, 8)
          ..saveLayer(
            const Rect.fromLTWH(0, 0, 24, 24),
            Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
          )
          ..scale(24 / picture.size.width, 24 / picture.size.height)
          ..drawPicture(picture.picture)
          ..restore()
          ..restore();
        final output = recorder.endRecording();
        final image = await output.toImage(
          (40 * ratio).ceil(),
          (40 * ratio).ceil(),
        );
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        output.dispose();
        picture.picture.dispose();
        if (mounted && generation == _generation && bytes != null) {
          setState(
            () => _icons[icon] = BitmapDescriptor.bytes(
              bytes.buffer.asUint8List(),
              imagePixelRatio: ratio,
            ),
          );
        }
      }
    } catch (e, stack) {
      reportError(
        e,
        stack,
        source: ErrorSource.handled,
        context: 'POI marker rasterization',
      );
    }
  }

  @override
  void didUpdateWidget(PoiMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
    if (!_fitted && widget.points.isNotEmpty && _map != null) _fit();
  }

  Future<void> _move(CameraUpdate update) async {
    final map = _map;
    if (map == null || !mounted) return;
    try {
      await map.animateCamera(update);
    } catch (e, stack) {
      if (mounted) {
        reportError(
          e,
          stack,
          source: ErrorSource.handled,
          context: 'POI camera',
        );
      }
    }
  }

  Future<void> _fit() async {
    if (widget.points.isEmpty) return;
    _fitted = true;
    var south = widget.points.first.latitude, north = south;
    var west = widget.points.first.longitude, east = west;
    for (final p in widget.points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }
    await _move(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            (south - .001).clamp(-90, 90),
            (west - .001).clamp(-180, 180),
          ),
          northeast: LatLng(
            (north + .001).clamp(-90, 90),
            (east + .001).clamp(-180, 180),
          ),
        ),
        48,
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    widget.controller._state = null;
    // GoogleMap owns and disposes its platform controller.
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GoogleMap(
    mapType: widget.mapType,
    initialCameraPosition: const CameraPosition(
      target: LatLng(21.484, 39.185),
      zoom: 14,
    ),
    onMapCreated: (controller) {
      _map = controller;
      _fit();
    },
    zoomControlsEnabled: false,
    mapToolbarEnabled: false,
    myLocationButtonEnabled: false,
    compassEnabled: false,
    padding: EdgeInsets.only(
      top: MediaQuery.paddingOf(context).top + 64,
      bottom: widget.bottomInset,
      left: 56,
      right: 56,
    ),
    markers: {
      for (final p in widget.points)
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude, p.longitude),
          icon:
              _icons[p.icon] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          anchor: const Offset(.5, .5),
          zIndexInt: p.id == widget.selectedId ? 1 : 0,
          infoWindow: InfoWindow(title: p.name),
          onTap: () => widget.onSelect(p),
        ),
    },
  );
}
