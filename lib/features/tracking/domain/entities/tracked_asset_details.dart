/// Everything the details screen's five tabs read.
///
/// One entity rather than one per tab: the tabs are views of a single asset
/// loaded once, and splitting it would mean five requests for one screen.
class TrackedAssetDetails {
  const TrackedAssetDetails({
    required this.assetId,
    required this.name,
    required this.equipmentType,
    required this.companyName,
    required this.managerName,
    required this.address,
    required this.speedKph,
    required this.durationHours,
    required this.connectionMinutesAgo,
    required this.lastGpsAt,
    required this.distanceKm,
    required this.fuelPercent,
    required this.idleHours,
    required this.tankLevelPercent,
    required this.temperatureCelsius,
    required this.weightKg,
    required this.sensorCode,
    required this.sensorBatteryMillivolts,
    required this.sensorDistanceKm,
    required this.fuelUsagePercent,
    required this.doorOpen,
    required this.engineOn,
  });

  final String assetId;

  // Identity. These were localisation keys, which made sample data look like
  // translated copy — a real asset's name is not a string the app ships.
  final String name;
  final String equipmentType;
  final String companyName;
  final String managerName;
  final String address;

  final int speedKph;
  final int durationHours;
  final int connectionMinutesAgo;
  final DateTime lastGpsAt;
  final double distanceKm;
  final int fuelPercent;
  final int idleHours;
  final int tankLevelPercent;
  final int temperatureCelsius;
  final int weightKg;
  final String sensorCode;
  final int sensorBatteryMillivolts;
  final int sensorDistanceKm;
  final int fuelUsagePercent;
  final bool doorOpen;
  final bool engineOn;
}

/// The alert kinds the notifications tab renders. The label for each is a
/// localisation key; the kind itself is data.
enum TrackingNotificationType { speeding, stopped, geofence }

class TrackedAssetNotification {
  const TrackedAssetNotification({
    required this.type,
    required this.date,
    required this.speedKph,
  });

  final TrackingNotificationType type;
  final DateTime date;
  final int speedKph;
}
