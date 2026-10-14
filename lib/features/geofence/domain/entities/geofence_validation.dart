import 'geofence_draft.dart';
import 'geofence.dart';
import 'geofence_limits.dart';

enum GeofenceIssue { nameRequired, nameTooLong, assetRequired, shapeRequired, polygonNeedsThreePoints, radiusOutOfRange, daysRequired, invalidTimeRange, invalidSpeedLimit }

abstract final class GeofenceValidator {
  static List<GeofenceIssue> validate(GeofenceDraft draft) {
    final issues=<GeofenceIssue>[];
    if(draft.name.trim().isEmpty) issues.add(GeofenceIssue.nameRequired);
    if(draft.name.length>200) issues.add(GeofenceIssue.nameTooLong);
    if(draft.assetIds.isEmpty) issues.add(GeofenceIssue.assetRequired);
    if(draft.shape==null) issues.add(GeofenceIssue.shapeRequired);
    if(draft.shape is PolygonShape && !draft.drawValid) issues.add(GeofenceIssue.polygonNeedsThreePoints);
    if(draft.shape is CircleShape) { final radius=(draft.shape as CircleShape).radiusMeters; if(radius<GeofenceLimits.minRadiusMeters||radius>GeofenceLimits.maxRadiusMeters) issues.add(GeofenceIssue.radiusOutOfRange); }
    if(draft.schedule is SpecificSchedule) { final schedule=draft.schedule as SpecificSchedule; if(schedule.days.isEmpty) issues.add(GeofenceIssue.daysRequired); if(schedule.end.minutes<=schedule.start.minutes) issues.add(GeofenceIssue.invalidTimeRange); }
    if(!draft.settingsValid) issues.add(GeofenceIssue.invalidSpeedLimit);
    return List.unmodifiable(issues);
  }
}
