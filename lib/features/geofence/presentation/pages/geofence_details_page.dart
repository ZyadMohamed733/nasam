import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/geofence.dart';
import '../cubit/geofence_editor_cubit.dart';
import '../map/geofence_map.dart';

class GeofenceDetailsPage extends StatelessWidget {
  const GeofenceDetailsPage({super.key, required this.geofenceId});

  final String geofenceId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<GeofenceEditorCubit, GeofenceEditorState>(
      builder: (context, s) {
        final g = s.draft;
        if (s.status == GeofenceEditorStatus.loading ||
            s.status == GeofenceEditorStatus.initial)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (s.status == GeofenceEditorStatus.failure)
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                s.failure?.code == '404' ? l.geofenceNotFound : l.errorGeneric,
              ),
            ),
          );
        final shape = g.shape;
        if (shape == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l.errorGeneric)),
          );
        }
        final center = shape is CircleShape
            ? shape.center
            : (shape as PolygonShape).points.first;
        final polygons = shape is PolygonShape && shape.points.length > 2
            ? {
                Polygon(
                  polygonId: const PolygonId('view'),
                  points: shape.points
                      .map((p) => LatLng(p.latitude, p.longitude))
                      .toList(),
                  strokeColor: geofenceColor(g.color),
                  fillColor: geofenceColor(g.color).withValues(alpha: .2),
                ),
              }
            : <Polygon>{};
        final circles = shape is CircleShape
            ? {
                Circle(
                  circleId: const CircleId('view'),
                  center: LatLng(center.latitude, center.longitude),
                  radius: shape.radiusMeters,
                  strokeColor: geofenceColor(g.color),
                  fillColor: geofenceColor(g.color).withValues(alpha: .2),
                ),
              }
            : <Circle>{};
        return Scaffold(
          appBar: AppBar(
            title: Text(g.name),
            actions: [
              IconButton(
                tooltip: l.poiEdit,
                onPressed: () =>
                    context.push(AppRoutes.geofenceEdit(geofenceId)),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(center.latitude, center.longitude),
                    zoom: 13,
                  ),
                  polygons: polygons,
                  circles: circles,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              const SizedBox(height: 16),
              _Section(title: l.geofenceName, value: g.name),
              _Section(title: l.geofenceAssets, value: g.assetIds.join(', ')),
              _Section(
                title: l.geofenceDrawTitle,
                value: shape is CircleShape
                    ? '${l.geofenceCircle} (${shape.radiusMeters.toStringAsFixed(0)}m)'
                    : '${l.geofencePolygon} (${(shape as PolygonShape).points.length})',
              ),
              _Section(
                title: l.geofenceStepsTime,
                value: g.schedule is AlwaysActive
                    ? l.geofenceAlways
                    : l.geofenceScheduled,
              ),
              _Section(
                title: l.geofenceSettings,
                value: [
                  if (g.settings.notifications) l.geofenceNotifications,
                  if (g.settings.activateGeofence) l.geofenceActivate,
                  if (g.settings.exitDetection) l.geofenceExit,
                  if (g.settings.speedMonitoring) l.geofenceSpeed,
                  if (g.settings.timeMonitoring) l.geofenceTime,
                ].join(' · '),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.value});

  final String title, value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    ),
  );
}
