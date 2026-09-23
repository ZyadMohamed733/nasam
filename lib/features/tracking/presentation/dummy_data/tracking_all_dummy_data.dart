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
