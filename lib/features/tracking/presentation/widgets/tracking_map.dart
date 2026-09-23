import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as clusters;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/tracking_vehicle.dart';
import '../tracking_style.dart';
import 'tracking_marker_factory.dart';

// Keep isolated vehicles visible at the initial fleet-wide camera zoom.
const trackingClusterLevels = <double>[1, 3, 5, 7, 8.5, 10, 13, 15, 17];

// google_maps_cluster_manager's onCameraMove only reads the zoom, so the
// target here is a placeholder shared by every manual camera-move call.
const _trackingCenter = LatLng(24.86, 46.40);

class VehicleMapItem with clusters.ClusterItem {
  VehicleMapItem(this.vehicle);
  final TrackingVehicle vehicle;
  @override
  LatLng get location => LatLng(vehicle.latitude, vehicle.longitude);
}

/// Adds a minimum span for coincident vehicles; null represents an empty fleet.
LatLngBounds? vehicleBounds(
  List<TrackingVehicle> vehicles, {
  double minimumSpan = .004,
}) {
  if (vehicles.isEmpty) return null;
  var south = vehicles.first.latitude, north = south;
  var west = vehicles.first.longitude, east = west;
  for (final v in vehicles.skip(1)) {
    if (v.latitude < south) south = v.latitude;
    if (v.latitude > north) north = v.latitude;
    if (v.longitude < west) west = v.longitude;
    if (v.longitude > east) east = v.longitude;
  }
  if (north - south < minimumSpan) {
    north += minimumSpan / 2;
    south -= minimumSpan / 2;
  }
  if (east - west < minimumSpan) {
    east += minimumSpan / 2;
    west -= minimumSpan / 2;
  }
  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}

class TrackingMap extends StatefulWidget {
  const TrackingMap({
    super.key,
    required this.vehicles,
    required this.bottomInset,
    this.onVehicleTap,
    this.mapType = MapType.normal,
    this.onMapReady,
  });
  final List<TrackingVehicle> vehicles;
  final double bottomInset;
  final ValueChanged<TrackingVehicle>? onVehicleTap;
  final MapType mapType;
  final ValueChanged<GoogleMapController>? onMapReady;
  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  GoogleMapController? _controller;
  late clusters.ClusterManager<VehicleMapItem> _manager;
  var _factory = TrackingMarkerFactory();
  Set<Marker> _markers = {};
  var _generation = 0;
  bool _ready = false;
  double _zoom = 11;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configure();
  }

  @override
  void didUpdateWidget(TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicles != widget.vehicles) {
      _configure();
      _fit();
    }
  }

  void _configure() {
    final generation = ++_generation;
    _factory = TrackingMarkerFactory();
    final factory = _factory;
    final l = AppLocalizations.of(context)!;
    final direction = Directionality.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final colors = {
      for (final s in VehicleStatus.values) s: TrackingStyle.status(context, s),
    };
    _manager = clusters.ClusterManager<VehicleMapItem>(
      widget.vehicles.map(VehicleMapItem.new).toList(),
      (_) {},
      levels: trackingClusterLevels,
      stopClusteringZoom: 17,
      markerBuilder: (cluster) async {
        final v = cluster.items.first.vehicle;
        final icon = cluster.isMultiple
            ? await factory.cluster(cluster.count, primary)
            : await factory.vehicle(
                label: '${l.trackingVehicle} ${v.id}',
                color: colors[v.status]!,
                heading: v.heading,
                direction: direction,
              );
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          anchor: cluster.isMultiple
              ? const Offset(.5, .5)
              : const Offset(.5, 25 / 78),
          icon: icon,
          consumeTapEvents: true,
          onTap: cluster.isMultiple
              ? () => _focusCluster(cluster)
              : () => widget.onVehicleTap?.call(v),
        );
      },
    );
    if (_ready) {
      _manager.setMapId(_controller!.mapId, withUpdate: false);
      _manager.onCameraMove(
        CameraPosition(target: _trackingCenter, zoom: _zoom),
      );
      if (mounted && generation == _generation) _refresh();
    }
  }

  Future<void> _refresh() async {
    if (!_ready) return;
    final generation = ++_generation;
    final manager = _manager;
    try {
      final groups = await manager.getMarkers();
      final markers = await Future.wait(groups.map(manager.markerBuilder));
      if (mounted && generation == _generation) {
        setState(() {
          _markers = markers.toSet();
          _mapFailed = false;
        });
      }
    } catch (_) {
      // Native map can be disposed while an outstanding camera query completes.
      if (mounted && generation == _generation) {
        setState(() => _mapFailed = true);
      }
    }
  }

  Future<void> _focusCluster(clusters.Cluster<VehicleMapItem> cluster) async {
    final controller = _controller;
    if (!mounted || !_ready || controller == null) return;
    // A tighter minimum than the fleet overview lets compact groups separate
    // into arrows. A nonzero span also handles vehicles sharing a location.
    final bounds = vehicleBounds(
      cluster.items.map((item) => item.vehicle).toList(),
      minimumSpan: .0004,
    );
    if (bounds == null) return;
    try {
      // GoogleMap.padding already reserves the bottom panel and map controls.
      // This extra inset keeps wide vehicle labels away from the viewport edge.
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    } catch (_) {
      if (mounted) setState(() => _mapFailed = true);
    }
    // onCameraIdle refreshes the clusters using the resulting camera zoom.
  }

  bool _mapFailed = false;
  Future<void> _fit() async {
    final bounds = vehicleBounds(widget.vehicles);
    if (_controller == null || bounds == null) return;
    await _controller!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 36));
  }

  @override
  void dispose() {
    _generation++;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(24.86, 46.40),
            zoom: 11,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 60,
            bottom: widget.bottomInset,
            left: 48,
            right: 8,
          ),
          markers: _markers,
          mapType: widget.mapType,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          onMapCreated: (controller) async {
            _controller = controller;
            widget.onMapReady?.call(controller);
            _manager.setMapId(controller.mapId, withUpdate: false);
            _manager.onCameraMove(
              CameraPosition(target: _trackingCenter, zoom: _zoom),
            );
            if (!mounted) return;
            _ready = true;
            await _fit();
            if (mounted) await _refresh();
          },
          onCameraMove: (position) {
            _zoom = position.zoom;
            _manager.onCameraMove(position);
            _generation++; // Discard renders for an older camera position.
          },
          onCameraIdle: () {
            _manager.onCameraMove(
              CameraPosition(target: _trackingCenter, zoom: _zoom),
            );
            _refresh();
          },
        ),
        if (widget.vehicles.isEmpty || _mapFailed)
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_mapFailed ? l.errorGeneric : l.emptyState),
              ),
            ),
          ),
      ],
    );
  }
}
