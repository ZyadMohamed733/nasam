/// How a vehicle is behaving right now. Drives the map marker, the summary
/// counts and the status filter, so the order here is the order the UI shows.
enum VehicleStatus { moving, idle, stopped, offline }

/// A vehicle as the map needs it: a position, a bearing and a state.
///
/// Deliberately smaller than `TrackedAsset`. The map draws thousands of these
/// and needs none of the fleet metadata; keeping them apart is what lets the
/// marker layer rebuild without touching the list.
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

  /// Degrees clockwise from north.
  final double heading;
}
