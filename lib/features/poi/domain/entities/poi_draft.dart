import 'poi_limits.dart';
import 'poi_validation.dart';

/// Stable API values; localized labels belong to presentation.
enum PoiIcon { location, hospital, library, fuel }

class PoiDraft {
  const PoiDraft({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.icon = PoiIcon.location,
    this.notes = '',
  });
  final String name;
  final double latitude;
  final double longitude;
  final PoiIcon icon;
  final String notes;
  bool get isValid =>
      PoiValidator.name(name) == null &&
      PoiValidator.notes(notes) == null &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= PoiLimits.maxLatitude &&
      longitude.abs() <= PoiLimits.maxLongitude;
}
