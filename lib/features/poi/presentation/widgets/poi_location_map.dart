import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/errors/error_reporter.dart';
import '../../../../shared/widgets/app_map_preview.dart';

/// The map behind the location preview and the full-screen picker. Its
/// marker is the design's pin ([AppMapPinPainter]) with its tip on the point.
class PoiLocationMap extends StatefulWidget {
  const PoiLocationMap({
    super.key,
    required this.point,
    this.onChanged,
    this.preview = false,
    this.showMarker = true,
  });
  final LatLng point;
  final ValueChanged<LatLng>? onChanged;
  final bool preview;

  /// Off where the pin is drawn over the map instead (`AppMapPreview`).
  final bool showMarker;
  @override
  State<PoiLocationMap> createState() => _PoiLocationMapState();
}

class _PoiLocationMapState extends State<PoiLocationMap> {
  GoogleMapController? _map;
  BitmapDescriptor? _icon;
  Color? _color, _dot;
  double? _ratio;
  int _generation = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final color = context.semanticColors.actionIcon;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    _dot = context.semanticColors.containerBackground;
    if (_color != color || _ratio != ratio) {
      _color = color;
      _ratio = ratio;
      _render(color, ratio);
    }
  }

  Future<void> _render(Color color, double ratio) async {
    final generation = ++_generation;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(ratio);
      AppMapPinPainter(
        color: color,
        dot: _dot ?? Colors.white,
      ).paint(canvas, const Size.square(AppMapPin.size));
      final output = recorder.endRecording();
      final image = await output.toImage(
        (AppMapPin.size * ratio).ceil(),
        (AppMapPin.size * ratio).ceil(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      output.dispose();
      if (mounted && generation == _generation && bytes != null) {
        setState(
          () => _icon = BitmapDescriptor.bytes(
            bytes.buffer.asUint8List(),
            imagePixelRatio: ratio,
          ),
        );
      }
    } catch (error, stack) {
      reportError(
        error,
        stack,
        source: ErrorSource.handled,
        context: 'POI location marker',
      );
    }
  }

  @override
  void didUpdateWidget(PoiLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.point != widget.point && widget.preview) _move();
  }

  Future<void> _move() async {
    try {
      await _map?.moveCamera(CameraUpdate.newLatLng(widget.point));
    } catch (error, stack) {
      if (mounted) {
        reportError(
          error,
          stack,
          source: ErrorSource.handled,
          context: 'POI location camera',
        );
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GoogleMap(
    initialCameraPosition: CameraPosition(target: widget.point, zoom: 16),
    onMapCreated: (map) => _map = map,
    onTap: widget.onChanged,
    zoomControlsEnabled: !widget.preview,
    mapToolbarEnabled: false,
    myLocationButtonEnabled: false,
    markers: {
      if (widget.showMarker)
        Marker(
          markerId: const MarkerId('location'),
          position: widget.point,
          draggable: widget.onChanged != null,
          onDragEnd: widget.onChanged,
          anchor: const Offset(.5, .5),
          icon:
              _icon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
    },
  );
}
