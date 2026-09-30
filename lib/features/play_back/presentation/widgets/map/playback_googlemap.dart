import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/errors/error_reporter.dart';
import '../../../../tracking/presentation/widgets/tracking_map.dart';
import '../../../../tracking/presentation/widgets/tracking_marker_factory.dart';
import '../../../domain/entities/playback_point.dart';

class PlaybackGoogleMap extends StatefulWidget {
  const PlaybackGoogleMap({
    required this.points,
    required this.index,
    required this.mapType,
    required this.bottomInset,
    required this.onCreated,
  });
  final List<PlaybackPoint> points;
  final int index;
  final MapType mapType;
  final double bottomInset;
  final ValueChanged<GoogleMapController> onCreated;
  @override
  State<PlaybackGoogleMap> createState() => PlaybackGoogleMapState();
}

class PlaybackGoogleMapState extends State<PlaybackGoogleMap> {
  GoogleMapController? _controller;
  TrackingMarkerFactory? _markerFactory;
  BitmapDescriptor? _currentMarkerIcon;
  int _markerGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_markerFactory == null) {
      _markerFactory = TrackingMarkerFactory(
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
      _updateCurrentMarker();
    }
  }

  @override
  void didUpdateWidget(covariant PlaybackGoogleMap old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  Future<void> _updateCurrentMarker() async {
    if (_markerFactory == null) return;
    final generation = ++_markerGeneration;
    try {
      final icon = await _markerFactory!.playbackCurrent();
      if (!mounted || generation != _markerGeneration) return;
      setState(() => _currentMarkerIcon = icon);
    } catch (error, stack) {
      reportError(error, stack, source: ErrorSource.handled);
    }
  }

  @override
  void dispose() {
    _markerGeneration++;
    _markerFactory?.dispose();
    super.dispose();
  }

  Future<void> _fit() async {
    final c = _controller;
    if (c == null || widget.points.isEmpty) {
      return;
    }
    final p = widget.points;
    double minLat = p.first.latitude,
        maxLat = minLat,
        minLng = p.first.longitude,
        maxLng = minLng;
    for (final x in p) {
      minLat = minLat < x.latitude ? minLat : x.latitude;
      maxLat = maxLat > x.latitude ? maxLat : x.latitude;
      minLng = minLng < x.longitude ? minLng : x.longitude;
      maxLng = maxLng > x.longitude ? maxLng : x.longitude;
    }
    try {
      await c.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          TrackingMapLayout.fleetFitPadding,
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    final p = widget.points;
    final start = LatLng(p.first.latitude, p.first.longitude),
        end = LatLng(p.last.latitude, p.last.longitude),
        current = p[widget.index.clamp(0, p.length - 1)];
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: start, zoom: 12),
      padding: EdgeInsetsDirectional.only(
        top:
        MediaQuery.paddingOf(context).top +
            TrackingMapLayout.topBarClearance,
        bottom: widget.bottomInset,
        start: TrackingMapLayout.toolColumnClearance,
        end: TrackingMapLayout.edgeInset,
      ).resolve(Directionality.of(context)),
      mapType: widget.mapType,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: p.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          color: Theme.of(context).colorScheme.primary,
          width: 3,
          geodesic: true,
        ),
      },
      markers: {
        Marker(
          markerId: const MarkerId('start'),
          position: start,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: end,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(current.latitude, current.longitude),
          rotation:
          (current.headingDegrees +
              TrackingMarkerFactory.playbackArrowBearingCorrection) %
              360,
          anchor: const Offset(.5, .5),
          icon:
          _currentMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      },
      onMapCreated: (c) {
        _controller = c;
        widget.onCreated(c);
        _fit();
      },
    );
  }
}