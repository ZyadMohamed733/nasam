import 'geofence.dart';
import 'geofence_limits.dart';

class GeofenceDraft {
  const GeofenceDraft({this.name = '', this.assetIds = const [], this.shape, this.color = GeofenceColor.purple, this.schedule = const AlwaysActive(), this.settings = const GeofenceSettings()});
  final String name;
  final List<String> assetIds;
  final GeofenceShape? shape;
  final GeofenceColor color;
  final GeofenceSchedule schedule;
  final GeofenceSettings settings;
  bool get infoValid => name.trim().isNotEmpty && name.length <= 200 && assetIds.isNotEmpty;
  bool get drawValid => shape is CircleShape && (shape as CircleShape).radiusMeters >= GeofenceLimits.minRadiusMeters && (shape as CircleShape).radiusMeters <= GeofenceLimits.maxRadiusMeters || (shape is PolygonShape && (shape as PolygonShape).points.length >= 3);
  bool get timeValid => schedule is AlwaysActive || (schedule is SpecificSchedule && (schedule as SpecificSchedule).days.isNotEmpty && (schedule as SpecificSchedule).end.minutes > (schedule as SpecificSchedule).start.minutes);
  bool get settingsValid => !settings.speedMonitoring || settings.speedLimitKph == null || settings.speedLimitKph! > 0;
  bool get isValid => infoValid && drawValid && timeValid && settingsValid;
}
