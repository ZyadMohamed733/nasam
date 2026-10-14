import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/geofence.dart';
import '../cubit/geofence_editor_cubit.dart';
import '../map/geofence_map.dart';

class GeofenceEditorPage extends StatefulWidget {
  const GeofenceEditorPage({super.key, this.geofenceId});

  final String? geofenceId;

  @override
  State<GeofenceEditorPage> createState() => _GeofenceEditorPageState();
}

class _GeofenceEditorPageState extends State<GeofenceEditorPage> {
  final _name = TextEditingController(), _assets = TextEditingController();
  bool _init = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.geofenceId == null) {
        context.read<GeofenceEditorCubit>().initCreate();
      } else {
        context.read<GeofenceEditorCubit>().load(widget.geofenceId!);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _assets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocConsumer<GeofenceEditorCubit, GeofenceEditorState>(
      listener: (context, s) {
        if (s.status == GeofenceEditorStatus.ready && !_init) {
          _name.text = s.draft.name;
          _assets.text = s.draft.assetIds.join(', ');
          _init = true;
        }
        if (s.status == GeofenceEditorStatus.saved)
          Navigator.of(context).pop(true);
      },
      builder: (context, s) {
        if (s.status == GeofenceEditorStatus.loading ||
            s.status == GeofenceEditorStatus.initial)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (s.status == GeofenceEditorStatus.failure && s.draft.name.isEmpty)
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                s.failure?.code == '404' ? l.geofenceNotFound : l.errorGeneric,
              ),
            ),
          );
        final cubit = context.read<GeofenceEditorCubit>();
        final titles = [
          l.geofenceStepsInfo,
          l.geofenceStepsDraw,
          l.geofenceStepsTime,
          l.geofenceStepsSettings,
          l.geofenceStepsReview,
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.geofenceId == null
                  ? l.geofenceCreateTitle
                  : l.geofenceEditTitle,
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: List.generate(
                    5,
                    (i) => Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: i <= s.currentStep
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            child: Text(
                              '${i + 1}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                            ),
                          ),
                          Text(
                            titles[i],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Center(child: _step(context, s, cubit, l)),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: s.currentStep == 0
                            ? () => Navigator.of(context).maybePop()
                            : cubit.previous,
                        child: Text(
                          s.currentStep == 0
                              ? l.geofenceCancel
                              : l.geofencePrevious,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: s.currentStep < 4
                            ? (s.stepValid ? cubit.next : null)
                            : () async {
                                await cubit.save();
                              },
                        child: Text(
                          s.currentStep < 4
                              ? l.geofenceNext
                              : widget.geofenceId == null
                              ? l.geofenceSave
                              : l.geofenceSaveChanges,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _step(
    BuildContext context,
    GeofenceEditorState s,
    GeofenceEditorCubit c,
    AppLocalizations l,
  ) {
    final d = s.draft;
    switch (s.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.geofenceName),
            TextField(
              controller: _name,
              onChanged: c.setName,
              decoration: InputDecoration(hintText: l.geofenceNameHint),
            ),
            const SizedBox(height: 16),
            Text(l.geofenceAssets),
            TextField(
              controller: _assets,
              onChanged: (v) => c.setAssets(
                v
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
              decoration: InputDecoration(hintText: l.geofenceAssetIdsHint),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.geofenceDrawTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l.geofencePolygon)),
                ButtonSegment(value: true, label: Text(l.geofenceCircle)),
              ],
              selected: {d.shape is CircleShape},
              onSelectionChanged: (v) {
                final circle = v.first;
                if (circle) {
                  c.setShape(const CircleShape(GeoPoint(24.86, 46.40), 1000));
                } else {
                  c.setShape(const PolygonShape([]));
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(24.86, 46.40),
                  zoom: 12,
                ),
                onTap: (p) {
                  final point = GeoPoint(p.latitude, p.longitude);
                  if (d.shape is CircleShape)
                    c.setShape(
                      CircleShape(point, (d.shape as CircleShape).radiusMeters),
                    );
                  else {
                    final old = d.shape is PolygonShape
                        ? (d.shape as PolygonShape).points
                        : const <GeoPoint>[];
                    c.setShape(PolygonShape([...old, point]));
                  }
                },
                markers: {
                  if (d.shape is CircleShape)
                    Marker(
                      markerId: const MarkerId('center'),
                      position: LatLng(
                        (d.shape as CircleShape).center.latitude,
                        (d.shape as CircleShape).center.longitude,
                      ),
                    ),
                },
                polygons: {
                  if (d.shape is PolygonShape &&
                      (d.shape as PolygonShape).points.length >= 3)
                    Polygon(
                      polygonId: const PolygonId('draft'),
                      points: (d.shape as PolygonShape).points
                          .map((p) => LatLng(p.latitude, p.longitude))
                          .toList(),
                      strokeColor: geofenceColor(d.color),
                      fillColor: geofenceColor(d.color).withValues(alpha: .2),
                    ),
                },
                circles: {
                  if (d.shape is CircleShape)
                    Circle(
                      circleId: const CircleId('draft'),
                      center: LatLng(
                        (d.shape as CircleShape).center.latitude,
                        (d.shape as CircleShape).center.longitude,
                      ),
                      radius: (d.shape as CircleShape).radiusMeters,
                      strokeColor: geofenceColor(d.color),
                      fillColor: geofenceColor(d.color).withValues(alpha: .2),
                    ),
                },
              ),
            ),
            if (d.shape case final CircleShape circle)
              Text(
                '${l.geofenceRadius}: ${circle.radiusMeters.toStringAsFixed(0)}',
              ),
            const SizedBox(height: 12),
            Text(l.geofenceColor),
            Wrap(
              spacing: 10,
              children: GeofenceColor.values
                  .map(
                    (color) => InkWell(
                      onTap: () => c.setColor(color),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: geofenceColor(color),
                        child: d.color == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (!d.drawValid)
              Text(
                l.errorGeneric,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.geofenceStepsTime,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l.geofenceAlways)),
                ButtonSegment(value: false, label: Text(l.geofenceScheduled)),
              ],
              selected: {d.schedule is AlwaysActive},
              onSelectionChanged: (v) {
                c.setSchedule(
                  v.first
                      ? const AlwaysActive()
                      : SpecificSchedule(
                          Weekday.values.toSet(),
                          const TimeOfDayValue(8, 0),
                          const TimeOfDayValue(17, 0),
                          true,
                        ),
                );
              },
            ),
            if (d.schedule is SpecificSchedule)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l.geofenceScheduledSummary),
              ),
          ],
        );
      case 3:
        final x = d.settings;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.geofenceSettings,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              title: Text(l.geofenceNotifications),
              value: x.notifications,
              onChanged: (v) => c.setSettings(
                GeofenceSettings(
                  notifications: v,
                  activateGeofence: x.activateGeofence,
                  exitDetection: x.exitDetection,
                  speedMonitoring: x.speedMonitoring,
                  speedLimitKph: x.speedLimitKph,
                  timeMonitoring: x.timeMonitoring,
                  reactivation: x.reactivation,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l.geofenceActivate),
              value: x.activateGeofence,
              onChanged: (v) => c.setSettings(
                GeofenceSettings(
                  notifications: x.notifications,
                  activateGeofence: v,
                  exitDetection: x.exitDetection,
                  speedMonitoring: x.speedMonitoring,
                  speedLimitKph: x.speedLimitKph,
                  timeMonitoring: x.timeMonitoring,
                  reactivation: x.reactivation,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l.geofenceExit),
              value: x.exitDetection,
              onChanged: (v) => c.setSettings(
                GeofenceSettings(
                  notifications: x.notifications,
                  activateGeofence: x.activateGeofence,
                  exitDetection: v,
                  speedMonitoring: x.speedMonitoring,
                  timeMonitoring: x.timeMonitoring,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l.geofenceSpeed),
              value: x.speedMonitoring,
              onChanged: (v) => c.setSettings(
                GeofenceSettings(
                  notifications: x.notifications,
                  activateGeofence: x.activateGeofence,
                  exitDetection: x.exitDetection,
                  speedMonitoring: v,
                  timeMonitoring: x.timeMonitoring,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l.geofenceTime),
              value: x.timeMonitoring,
              onChanged: (v) => c.setSettings(
                GeofenceSettings(
                  notifications: x.notifications,
                  activateGeofence: x.activateGeofence,
                  exitDetection: x.exitDetection,
                  speedMonitoring: x.speedMonitoring,
                  timeMonitoring: v,
                ),
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.geofenceDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(title: Text(l.geofenceName), subtitle: Text(d.name)),
            ListTile(
              title: Text(l.geofenceAssets),
              subtitle: Text(d.assetIds.join('، ')),
            ),
            ListTile(
              title: Text(l.geofenceDrawTitle),
              subtitle: Text(
                d.shape is CircleShape ? l.geofenceCircle : l.geofencePolygon,
              ),
            ),
            ListTile(
              title: Text(l.geofenceStepsTime),
              subtitle: Text(
                d.schedule is AlwaysActive
                    ? l.geofenceAlways
                    : l.geofenceScheduled,
              ),
            ),
            ListTile(
              title: Text(l.geofenceSettings),
              subtitle: Text(
                [
                  if (d.settings.notifications) l.geofenceNotifications,
                  if (d.settings.activateGeofence) l.geofenceActivate,
                  if (d.settings.exitDetection) l.geofenceExit,
                  if (d.settings.speedMonitoring) l.geofenceSpeed,
                  if (d.settings.timeMonitoring) l.geofenceTime,
                ].join('، '),
              ),
            ),
          ],
        );
    }
  }
}
