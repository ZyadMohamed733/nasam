import 'tracking_vehicle.dart';

/// An asset as the list and the summary need it.
///
/// [id] is what the routes carry and what the details and playback screens
/// load by, so it is required rather than derived from a list position — a
/// deep link has no list to index into.
class TrackedAsset {
  const TrackedAsset({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.assignedPerson,
    required this.routeProgress,
  });

  final String id;
  final String name;
  final String code;
  final VehicleStatus status;
  final String assignedPerson;

  /// 0..1 along the asset's current route.
  final double routeProgress;
}
