enum GeofenceColor { purple, green, orange, red, magenta, blue, grey, gold }
enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday, saturday }
enum GeofenceReactivation { manual, afterEntry, afterExit }

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
  @override
  bool operator ==(Object other) => other is GeoPoint && latitude == other.latitude && longitude == other.longitude;
  @override
  int get hashCode => Object.hash(latitude, longitude);
}

sealed class GeofenceShape { const GeofenceShape(); }
class PolygonShape extends GeofenceShape {
  const PolygonShape(this.points);
  final List<GeoPoint> points;
}
class CircleShape extends GeofenceShape {
  const CircleShape(this.center, this.radiusMeters);
  final GeoPoint center;
  final double radiusMeters;
}

sealed class GeofenceSchedule { const GeofenceSchedule(); }
class AlwaysActive extends GeofenceSchedule { const AlwaysActive(); }
class TimeOfDayValue {
  const TimeOfDayValue(this.hour, this.minute);
  final int hour, minute;
  int get minutes => hour * 60 + minute;
  @override
  bool operator ==(Object o) => o is TimeOfDayValue && hour == o.hour && minute == o.minute;
  @override
  int get hashCode => Object.hash(hour, minute);
}
class SpecificSchedule extends GeofenceSchedule {
  const SpecificSchedule(this.days, this.start, this.end, this.repeatsWeekly);
  final Set<Weekday> days;
  final TimeOfDayValue start, end;
  final bool repeatsWeekly;
}

class GeofenceSettings {
  const GeofenceSettings({this.notifications = true, this.activateGeofence = true, this.exitDetection = true, this.speedMonitoring = false, this.speedLimitKph, this.timeMonitoring = false, this.reactivation});
  final bool notifications, activateGeofence, exitDetection, speedMonitoring, timeMonitoring;
  final int? speedLimitKph;
  final GeofenceReactivation? reactivation;
}

class Geofence {
  const Geofence({required this.id, required this.name, required this.assetIds, required this.shape, required this.colorValue, required this.schedule, required this.settings});
  final String id, name;
  final List<String> assetIds;
  final GeofenceShape shape;
  final GeofenceColor colorValue;
  final GeofenceSchedule schedule;
  final GeofenceSettings settings;
}

class GeofenceAssetOption {
  const GeofenceAssetOption({required this.id, required this.name, required this.code});
  final String id, name, code;
}
