enum VehicleStatus { moving, idle, stopped, offline }

class TrackingVehicle {
  const TrackingVehicle({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.heading = 0,
  });

  final String id;
  final double latitude;
  final double longitude;
  final VehicleStatus status;
  final double heading;
}

abstract interface class TrackingRepository {
  Future<List<TrackingVehicle>> getVehicles();
}
