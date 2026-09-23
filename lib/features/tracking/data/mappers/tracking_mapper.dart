import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../../domain/entities/tracking_playback_segment.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../models/asset_details_model.dart';
import '../models/notification_model.dart';
import '../models/playback_segment_model.dart';
import '../models/tracked_asset_model.dart';
import '../models/vehicle_model.dart';

/// Wire models to domain entities.
///
/// Enum wire values are converted here and nowhere else. An unknown value
/// throws a [FormatException], matching the auth mapper: a status the app does
/// not know how to draw is a contract change, and the repository surfaces it
/// as a failure rather than letting a guessed status reach the map.
abstract final class TrackingMapper {
  static TrackingVehicle vehicle(VehicleModel m) => TrackingVehicle(
    id: m.id,
    assetId: m.assetId,
    latitude: m.latitude,
    longitude: m.longitude,
    status: _status(m.status),
    heading: m.heading,
  );

  static TrackedAsset asset(TrackedAssetModel m) => TrackedAsset(
    id: m.id,
    name: m.name,
    code: m.code,
    status: _status(m.status),
    assignedPerson: m.assignedPerson,
    routeProgress: m.routeProgress.clamp(0, 1).toDouble(),
  );

  static TrackedAssetDetails details(AssetDetailsModel m) =>
      TrackedAssetDetails(
        assetId: m.assetId,
        name: m.name,
        equipmentType: m.equipmentType,
        companyName: m.companyName,
        managerName: m.managerName,
        address: m.address,
        speedKph: m.speedKph,
        durationHours: m.durationHours,
        connectionMinutesAgo: m.connectionMinutesAgo,
        lastGpsAt: m.lastGpsAt,
        distanceKm: m.distanceKm,
        fuelPercent: m.fuelPercent,
        idleHours: m.idleHours,
        tankLevelPercent: m.tankLevelPercent,
        temperatureCelsius: m.temperatureCelsius,
        weightKg: m.weightKg,
        sensorCode: m.sensorCode,
        sensorBatteryMillivolts: m.sensorBatteryMillivolts,
        sensorDistanceKm: m.sensorDistanceKm,
        fuelUsagePercent: m.fuelUsagePercent,
        doorOpen: m.doorOpen,
        engineOn: m.engineOn,
      );

  static TrackedAssetNotification notification(NotificationModel m) =>
      TrackedAssetNotification(
        type: _notificationType(m.type),
        date: m.date,
        speedKph: m.speedKph,
      );

  static TrackingPlaybackSegment segment(PlaybackSegmentModel m) =>
      TrackingPlaybackSegment(
        startedAt: m.startedAt,
        endedAt: m.endedAt,
        distanceKm: m.distanceKm,
        durationMinutes: m.durationMinutes,
        maxSpeedKph: m.maxSpeedKph,
        startPlace: m.startPlace,
        endPlace: m.endPlace,
      );

  static VehicleStatus _status(String value) => switch (value) {
    'MOVING' => VehicleStatus.moving,
    'IDLE' => VehicleStatus.idle,
    'STOPPED' => VehicleStatus.stopped,
    'OFFLINE' => VehicleStatus.offline,
    _ => throw FormatException('Unknown vehicle status from API: "$value"'),
  };

  static TrackingNotificationType _notificationType(String value) =>
      switch (value) {
        'SPEEDING' => TrackingNotificationType.speeding,
        'STOPPED' => TrackingNotificationType.stopped,
        'GEOFENCE' => TrackingNotificationType.geofence,
        _ => throw FormatException(
          'Unknown notification type from API: "$value"',
        ),
      };
}
