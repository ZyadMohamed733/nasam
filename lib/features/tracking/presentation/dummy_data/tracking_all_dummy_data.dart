import '../../domain/tracking_vehicle.dart';

class TrackingAllDummyVehicle {
  const TrackingAllDummyVehicle({
    required this.name,
    required this.code,
    required this.status,
    required this.driver,
    required this.routeProgress,
  });

  final String name;
  final String code;
  final VehicleStatus status;
  final String driver;
  final double routeProgress;
}

abstract final class TrackingAllDummyData {
  static const vehicles = <TrackingAllDummyVehicle>[
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٢',
      code: 'VAN-0017',
      status: VehicleStatus.moving,
      driver: 'Aya Al-Rashidi',
      routeProgress: .62,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٢',
      code: 'VAN-0017',
      status: VehicleStatus.idle,
      driver: 'Aya Al-Rashidi',
      routeProgress: .38,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٢',
      code: 'VAN-0017',
      status: VehicleStatus.stopped,
      driver: 'Aya Al-Rashidi',
      routeProgress: .18,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٣',
      code: 'VAN-0021',
      status: VehicleStatus.moving,
      driver: 'Omar Hassan',
      routeProgress: .78,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٤',
      code: 'VAN-0024',
      status: VehicleStatus.idle,
      driver: 'Mona Ali',
      routeProgress: .45,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٥',
      code: 'VAN-0030',
      status: VehicleStatus.offline,
      driver: 'Khaled Nabil',
      routeProgress: .25,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٦',
      code: 'VAN-0032',
      status: VehicleStatus.stopped,
      driver: 'Nour Samir',
      routeProgress: .12,
    ),
    TrackingAllDummyVehicle(
      name: 'فان التوزيع ٧',
      code: 'VAN-0040',
      status: VehicleStatus.offline,
      driver: 'Youssef Adel',
      routeProgress: .05,
    ),
  ];
}

class TrackingVehicleDetailsSample {
  const TrackingVehicleDetailsSample({
    required this.plateNumber,
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

  final String plateNumber;
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

class TrackingVehicleNotificationSample {
  const TrackingVehicleNotificationSample({
    required this.type,
    required this.date,
    required this.speedKph,
  });

  final TrackingDummyNotificationType type;
  final DateTime date;
  final int speedKph;
}

abstract final class TrackingVehicleDetailsDummyData {
  static final details = TrackingVehicleDetailsSample(
    plateNumber: '154562',
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

  static final notifications = <TrackingVehicleNotificationSample>[
    TrackingVehicleNotificationSample(
      type: TrackingDummyNotificationType.speeding,
      date: DateTime(2025, 10, 17, 9, 0),
      speedKph: 13,
    ),
    TrackingVehicleNotificationSample(
      type: TrackingDummyNotificationType.stopped,
      date: DateTime(2025, 10, 17, 8, 12),
      speedKph: 13,
    ),
    TrackingVehicleNotificationSample(
      type: TrackingDummyNotificationType.geofence,
      date: DateTime(2025, 10, 17, 7, 36),
      speedKph: 13,
    ),
  ];
}
