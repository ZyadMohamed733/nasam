import '../../domain/tracking_vehicle.dart';

class TrackingAllDummyAsset {
  const TrackingAllDummyAsset({
    required this.name,
    required this.code,
    required this.status,
    required this.assignedPerson,
    required this.routeProgress,
  });

  final String name;
  final String code;
  final VehicleStatus status;
  final String assignedPerson;
  final double routeProgress;
}

abstract final class TrackingAllDummyData {
  static const assets = <TrackingAllDummyAsset>[
    TrackingAllDummyAsset(
      name: 'الأصل ٢',
      code: 'AST-0017',
      status: VehicleStatus.moving,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .62,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٢',
      code: 'AST-0017',
      status: VehicleStatus.idle,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .38,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٢',
      code: 'AST-0017',
      status: VehicleStatus.stopped,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .18,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٣',
      code: 'AST-0021',
      status: VehicleStatus.moving,
      assignedPerson: 'Omar Hassan',
      routeProgress: .78,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٤',
      code: 'AST-0024',
      status: VehicleStatus.idle,
      assignedPerson: 'Mona Ali',
      routeProgress: .45,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٥',
      code: 'AST-0030',
      status: VehicleStatus.offline,
      assignedPerson: 'Khaled Nabil',
      routeProgress: .25,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٦',
      code: 'AST-0032',
      status: VehicleStatus.stopped,
      assignedPerson: 'Nour Samir',
      routeProgress: .12,
    ),
    TrackingAllDummyAsset(
      name: 'الأصل ٧',
      code: 'AST-0040',
      status: VehicleStatus.offline,
      assignedPerson: 'Youssef Adel',
      routeProgress: .05,
    ),
  ];
}

class TrackingAssetDetailsSample {
  const TrackingAssetDetailsSample({
    required this.assetId,
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

enum TrackingDummyNotificationType { speeding, stopped, geofence }

class TrackingAssetNotificationSample {
  const TrackingAssetNotificationSample({
    required this.type,
    required this.date,
    required this.speedKph,
  });

  final TrackingDummyNotificationType type;
  final DateTime date;
  final int speedKph;
}

abstract final class TrackingAssetDetailsDummyData {
  static final details = TrackingAssetDetailsSample(
    assetId: '154562',
    speedKph: 13,
    durationHours: 78,
    connectionMinutesAgo: 2,
    lastGpsAt: DateTime(2025, 10, 17, 9, 0),
    distanceKm: 125.48,
    fuelPercent: 96,
    idleHours: 26,
    tankLevelPercent: 74,
    temperatureCelsius: 26,
    weightKg: 2450,
    sensorCode: 'IO9',
    sensorBatteryMillivolts: 2625,
    sensorDistanceKm: 11752,
    fuelUsagePercent: 38,
    doorOpen: false,
    engineOn: true,
  );

  static final notifications = <TrackingAssetNotificationSample>[
    TrackingAssetNotificationSample(
      type: TrackingDummyNotificationType.speeding,
      date: DateTime(2025, 10, 17, 9, 0),
      speedKph: 13,
    ),
    TrackingAssetNotificationSample(
      type: TrackingDummyNotificationType.stopped,
      date: DateTime(2025, 10, 17, 8, 12),
      speedKph: 13,
    ),
    TrackingAssetNotificationSample(
      type: TrackingDummyNotificationType.geofence,
      date: DateTime(2025, 10, 17, 7, 36),
      speedKph: 13,
    ),
  ];
}
