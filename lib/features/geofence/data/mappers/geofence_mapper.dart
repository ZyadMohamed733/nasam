import '../../domain/entities/geofence.dart';
import '../../domain/entities/geofence_draft.dart';
import '../models/geofence_model.dart';

class GeofenceMapper {
  static T _enum<T extends Enum>(List<T> values, dynamic value) => values.firstWhere((e) => e.name == value, orElse: () => throw FormatException('Unknown enum: $value'));
  static GeoPoint _point(dynamic raw) { final p = raw as Map<String, dynamic>; return GeoPoint((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble()); }
  static Geofence fromModel(GeofenceModel model) {
    final j = model.json, shapeJson = j['shape'] as Map<String, dynamic>;
    final shape = shapeJson['type'] == 'circle' ? CircleShape(_point(shapeJson['center']), (shapeJson['radiusMeters'] as num).toDouble()) : shapeJson['type'] == 'polygon' ? PolygonShape((shapeJson['points'] as List).map(_point).toList()) : throw FormatException('Unknown shape ${shapeJson['type']}');
    final s = j['schedule'] as Map<String, dynamic>;
    final schedule = s['type'] == 'always' ? const AlwaysActive() : s['type'] == 'specific' ? SpecificSchedule((s['days'] as List).map((e) => _enum(Weekday.values, e)).toSet(), TimeOfDayValue(s['startHour'] as int, s['startMinute'] as int), TimeOfDayValue(s['endHour'] as int, s['endMinute'] as int), s['repeatsWeekly'] as bool) : throw FormatException('Unknown schedule ${s['type']}');
    final x = j['settings'] as Map<String, dynamic>;
    return Geofence(id: j['id'] as String, name: j['name'] as String, assetIds: (j['assetIds'] as List).cast<String>(), shape: shape, colorValue: _enum(GeofenceColor.values, j['color'] ?? 'purple'), schedule: schedule, settings: GeofenceSettings(notifications: x['notifications'] as bool, activateGeofence: x['activateGeofence'] as bool, exitDetection: x['exitDetection'] as bool, speedMonitoring: x['speedMonitoring'] as bool, speedLimitKph: x['speedLimitKph'] as int?, timeMonitoring: x['timeMonitoring'] as bool, reactivation: x['reactivation'] == null ? null : _enum(GeofenceReactivation.values, x['reactivation'])));
  }
  static GeofenceModel toModel(GeofenceDraft d, String id) {
    final shape = d.shape;
    final shapeJson = switch (shape) { PolygonShape(:final points) => {'type':'polygon','points':points.map((p)=>{'latitude':p.latitude,'longitude':p.longitude}).toList()}, CircleShape(:final center, :final radiusMeters) => {'type':'circle','center':{'latitude':center.latitude,'longitude':center.longitude},'radiusMeters':radiusMeters}, null => throw const FormatException('Missing shape') };
    final scheduleJson = switch (d.schedule) { AlwaysActive() => {'type':'always'}, SpecificSchedule(:final days,:final start,:final end,:final repeatsWeekly) => {'type':'specific','days':days.map((e)=>e.name).toList(),'startHour':start.hour,'startMinute':start.minute,'endHour':end.hour,'endMinute':end.minute,'repeatsWeekly':repeatsWeekly} };
    final x=d.settings;
    return GeofenceModel({'id':id,'name':d.name.trim(),'assetIds':d.assetIds,'shape':shapeJson,'color':d.color.name,'schedule':scheduleJson,'settings':{'notifications':x.notifications,'activateGeofence':x.activateGeofence,'exitDetection':x.exitDetection,'speedMonitoring':x.speedMonitoring,'speedLimitKph':x.speedLimitKph,'timeMonitoring':x.timeMonitoring,'reactivation':x.reactivation?.name}});
  }
  static GeofenceAssetOption asset(Map<String, dynamic> j) => GeofenceAssetOption(id:j['id'] as String,name:j['name'] as String,code:j['code'] as String);
  static GeofenceDraft toDraft(Geofence g) => GeofenceDraft(name:g.name,assetIds:g.assetIds,shape:g.shape,color:g.colorValue,schedule:g.schedule,settings:g.settings);
}
