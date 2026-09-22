import '../domain/tracking_vehicle.dart';

/// Deterministic groups around Al Uyaynah, plus isolated vehicles.
class DummyTrackingRepository implements TrackingRepository {
  @override
  Future<List<TrackingVehicle>> getVehicles() async {
    final vehicles = <TrackingVehicle>[];
    const groups = [
      (24.925, 46.355, 15),
      (24.890, 46.410, 10),
      (24.845, 46.367, 5),
      (24.820, 46.397, 15),
      (24.791, 46.431, 20),
    ];
    for (final group in groups) {
      for (var i = 0; i < group.$3; i++) {
        vehicles.add(
          TrackingVehicle(
            id: '${vehicles.length + 1}',
            latitude: group.$1 + (i % 5) * .00015,
            longitude: group.$2 + (i ~/ 5) * .00015,
            status: VehicleStatus.values[i % 4],
            heading: (i % 8) * 45,
          ),
        );
      }
    }
    vehicles.addAll(const [
      TrackingVehicle(
        id: '66',
        latitude: 24.866,
        longitude: 46.401,
        status: VehicleStatus.stopped,
      ),
      TrackingVehicle(
        id: '67',
        latitude: 24.842,
        longitude: 46.443,
        status: VehicleStatus.moving,
      ),
      TrackingVehicle(
        id: '68',
        latitude: 24.805,
        longitude: 46.355,
        status: VehicleStatus.offline,
      ),
    ]);
    return List.unmodifiable(vehicles);
  }
}
