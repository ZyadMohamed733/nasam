import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/errors/error_reporter.dart';

/// The design's location pin, shared by preview and full-screen selection.
class PoiLocationMap extends StatefulWidget {
  const PoiLocationMap({
    super.key,
    required this.point,
    this.onChanged,
    this.preview = false,
  });
  final LatLng point;
  final ValueChanged<LatLng>? onChanged;
  final bool preview;
  @override
  State<PoiLocationMap> createState() => _PoiLocationMapState();
}

class _PoiLocationMapState extends State<PoiLocationMap> {
  GoogleMapController? _map;
  BitmapDescriptor? _icon;
  Color? _color;
  double? _ratio;
  int _generation = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final color = Theme.of(context).colorScheme.primary;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    if (_color != color || _ratio != ratio) {
      _color = color;
      _ratio = ratio;
      _render(color, ratio);
    }
  }

  Future<void> _render(Color color, double ratio) async {
    final generation = ++_generation;
    try {
      final picture = await vg.loadPicture(
        SvgStringLoader(await rootBundle.loadString(AppAssets.poiPin)),
        null,
      );
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(ratio);
      canvas.drawOval(
        const Rect.fromLTWH(4, 44, 64, 28),
        Paint()..color = color.withValues(alpha: .15),
      );
      canvas.drawOval(
        const Rect.fromLTWH(14, 48, 44, 20),
        Paint()..color = color.withValues(alpha: .15),
      );
      canvas
        ..saveLayer(
          const Rect.fromLTWH(0, 0, 72, 72),
          Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
        )
        ..translate(8, 4)
        ..scale(56 / picture.size.width, 56 / picture.size.height)
        ..drawPicture(picture.picture)
        ..restore();
      final output = recorder.endRecording();
      final image = await output.toImage(
        (72 * ratio).ceil(),
        (72 * ratio).ceil(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      output.dispose();
      picture.picture.dispose();
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
      Marker(
        markerId: const MarkerId('location'),
        position: widget.point,
        draggable: widget.onChanged != null,
        onDragEnd: widget.onChanged,
        anchor: const Offset(.5, .8),
        icon:
            _icon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    },
  );
}
