import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as clusters;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/errors/error_reporter.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../tracking_style.dart';
import 'tracking_marker_factory.dart';

// Keep isolated vehicles visible at the initial fleet-wide camera zoom.
const trackingClusterLevels = <double>[1, 3, 5, 7, 8.5, 10, 13, 15, 17];

/// The map's fixed numbers, named.
abstract final class TrackingMapLayout {
  /// Riyadh, city-wide: where the camera starts before the fleet is fitted.
  static const initialCamera = CameraPosition(
    target: LatLng(24.86, 46.40),
    zoom: 11,
  );

  /// The zoom used when fitting the fleet's bounds fails — typically because
  /// the map has not been laid out yet — centred on those bounds instead.
  static const double fallbackZoom = 11;

  /// Below this zoom, nearby vehicles are grouped into a count.
  static const double stopClusteringZoom = 17;

  /// Room kept clear under the status bar for the menu and search row.
  static const double topBarClearance = 60;

  /// Room kept clear on the left for the column of map tools.
  static const double toolColumnClearance = 48;

  /// Breathing room on the side with no controls.
  static const double edgeInset = 8;

  /// Extra margin around the whole fleet when it is fitted to the screen.
  static const double fleetFitPadding = 36;

  /// Extra margin around a tapped cluster, wider than [fleetFitPadding] so
  /// the labels of the vehicles it splits into stay on screen.
  static const double clusterFocusPadding = 64;
}

// google_maps_cluster_manager's onCameraMove only reads the zoom, so the
// target here is a placeholder shared by every manual camera-move call.
final _trackingCenter = TrackingMapLayout.initialCamera.target;

/// The middle of [bounds]. Not antimeridian-aware; the fleet is in one
/// country.
LatLng boundsCenter(LatLngBounds bounds) => LatLng(
  (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
  (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
);

/// Lets the page move the map without holding the native controller.
///
/// The page outlives no map, but a map can be disposed while a button press
/// is on its way; the native controller throws when used after that. This
/// goes through the live map or does nothing.
class TrackingMapController {
  _TrackingMapState? _map;

  bool get isAttached => _map != null;

  Future<void> zoomIn() => _map?._animate(CameraUpdate.zoomIn()) ?? _done;

  Future<void> zoomOut() => _map?._animate(CameraUpdate.zoomOut()) ?? _done;

  static final Future<void> _done = Future<void>.value();
}

/// What the marker bitmaps are drawn from. The factory, and with it every
/// cached bitmap, is rebuilt only when this changes — not on every
/// dependency change: a keyboard or a status-bar change moves MediaQuery
/// padding, which must not redraw the fleet.
@immutable
class _MarkerStyle {
  const _MarkerStyle({
    required this.locale,
    required this.direction,
    required this.scheme,
    required this.statusColors,
    required this.pixelRatio,
  });

  final Locale locale;
  final TextDirection direction;
  final ColorScheme scheme;
  final List<Color> statusColors;
  final double pixelRatio;

  @override
  bool operator ==(Object other) =>
      other is _MarkerStyle &&
      other.locale == locale &&
      other.direction == direction &&
      other.scheme == scheme &&
      listEquals(other.statusColors, statusColors) &&
      other.pixelRatio == pixelRatio;

  @override
  int get hashCode => Object.hash(
    locale,
    direction,
    scheme,
    Object.hashAll(statusColors),
    pixelRatio,
  );
}

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
    this.controller,
    this.markerFactoryBuilder,
  });
  final List<TrackingVehicle> vehicles;
  final double bottomInset;
  final ValueChanged<TrackingVehicle>? onVehicleTap;
  final MapType mapType;

  /// Attached while this map is mounted; see [TrackingMapController].
  final TrackingMapController? controller;

  /// Builds the marker factory for a pixel ratio. Overridable in tests,
  /// where the arrow artwork cannot come from the asset bundle.
  final TrackingMarkerFactory Function(double pixelRatio)? markerFactoryBuilder;

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  /// Owned by [GoogleMap], which disposes it; this only drops the reference.
  GoogleMapController? _controller;
  late clusters.ClusterManager<VehicleMapItem> _manager;
  TrackingMarkerFactory? _factory;
  _MarkerStyle? _style;
  Set<Marker> _markers = {};
  var _generation = 0;
  bool _ready = false;
  bool _mapFailed = false;
  double _zoom = TrackingMapLayout.initialCamera.zoom;

  /// Bitmaps are drawn off screen with the app font. The end of the first
  /// frame is the point by which the engine has resolved the bundled Almarai
  /// family for on-screen text, so no marker is drawn before it and none can
  /// fall back to a system face.
  final Future<void> _firstFrame = SchedulerBinding.instance.endOfFrame;

  @visibleForTesting
  TrackingMarkerFactory? get markerFactory => _factory;

  @override
  void initState() {
    super.initState();
    widget.controller?._map = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final style = _currentStyle();
    if (style == _style) return;
    _style = style;
    _factory?.dispose();
    _factory =
        (widget.markerFactoryBuilder ??
        (ratio) => TrackingMarkerFactory(pixelRatio: ratio))(style.pixelRatio);
    _configure();
  }

  @override
  void didUpdateWidget(TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._map == this) oldWidget.controller?._map = null;
      widget.controller?._map = this;
    }
    if (oldWidget.vehicles != widget.vehicles) {
      _configure();
      _fit();
    }
  }

  _MarkerStyle _currentStyle() => _MarkerStyle(
    locale: Localizations.localeOf(context),
    direction: Directionality.of(context),
    scheme: Theme.of(context).colorScheme,
    statusColors: [
      for (final s in VehicleStatus.values) TrackingStyle.status(context, s),
    ],
    pixelRatio: MediaQuery.devicePixelRatioOf(context),
  );

  void _configure() {
    final generation = ++_generation;
    final factory = _factory!;
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
      stopClusteringZoom: TrackingMapLayout.stopClusteringZoom,
      markerBuilder: (cluster) async {
        final v = cluster.items.first.vehicle;
        BitmapDescriptor icon;
        try {
          icon = cluster.isMultiple
              ? await factory.cluster(cluster.count, primary)
              : await factory.vehicle(
                  label: '${l.trackingAsset} ${v.id}',
                  color: colors[v.status]!,
                  heading: v.heading,
                  direction: direction,
                );
        } on MarkerDrawException catch (e, stack) {
          // One bad bitmap must not blank the fleet: this vehicle gets the
          // stock pin, and the next refresh draws it again.
          reportError(e, stack, source: ErrorSource.handled);
          icon = BitmapDescriptor.defaultMarker;
        }
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          anchor: cluster.isMultiple
              ? TrackingMarkerFactory.clusterAnchor
              : TrackingMarkerFactory.vehicleAnchor,
          icon: icon,
          consumeTapEvents: true,
          onTap: cluster.isMultiple
              ? () => _focusCluster(cluster)
              : () => widget.onVehicleTap?.call(v),
        );
      },
    );
    final controller = _controller;
    if (_ready && controller != null) {
      _manager.setMapId(controller.mapId, withUpdate: false);
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
      await _firstFrame;
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

  /// Moves the camera if the map is still there; a no-op otherwise.
  Future<void> _animate(CameraUpdate update) async {
    final controller = _controller;
    if (!mounted || controller == null) return;
    try {
      await controller.animateCamera(update);
    } catch (_) {
      // Disposed between the check and the call; nothing to move.
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
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          TrackingMapLayout.clusterFocusPadding,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _mapFailed = true);
    }
    // onCameraIdle refreshes the clusters using the resulting camera zoom.
  }

  /// Frames the whole fleet. Never throws: fitting bounds fails on some
  /// platforms before the map has a size, and a failed fit must not stop
  /// the markers being drawn — it falls back to the bounds' centre instead.
  Future<void> _fit() async {
    final controller = _controller;
    final bounds = vehicleBounds(widget.vehicles);
    if (controller == null || bounds == null) return;
    try {
      await controller.moveCamera(
        CameraUpdate.newLatLngBounds(bounds, TrackingMapLayout.fleetFitPadding),
      );
    } catch (_) {
      try {
        await controller.moveCamera(
          CameraUpdate.newLatLngZoom(
            boundsCenter(bounds),
            TrackingMapLayout.fallbackZoom,
          ),
        );
        _zoom = TrackingMapLayout.fallbackZoom;
      } catch (_) {
        // The map is gone or not ready at all; it stays where it started.
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    if (widget.controller?._map == this) widget.controller?._map = null;
    // GoogleMap disposes the native controller itself; disposing it here
    // too would do it twice.
    _controller = null;
    _factory?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: TrackingMapLayout.initialCamera,
          padding: EdgeInsets.only(
            top:
                MediaQuery.paddingOf(context).top +
                TrackingMapLayout.topBarClearance,
            bottom: widget.bottomInset,
            left: TrackingMapLayout.toolColumnClearance,
            right: TrackingMapLayout.edgeInset,
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
            if (!mounted) return;
            _controller = controller;
            _manager.setMapId(controller.mapId, withUpdate: false);
            _manager.onCameraMove(
              CameraPosition(target: _trackingCenter, zoom: _zoom),
            );
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
