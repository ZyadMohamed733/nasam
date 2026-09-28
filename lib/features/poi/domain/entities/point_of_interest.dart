import 'poi_draft.dart';

/// A saved location. Coordinates are geographic degrees, never screen pixels.
class PointOfInterest {
  const PointOfInterest({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.icon = PoiIcon.location,
    this.notes = '',
  });
  final PoiIcon icon;
  final String notes;
  PoiDraft get draft => PoiDraft(
    name: name,
    latitude: latitude,
    longitude: longitude,
    icon: icon,
    notes: notes,
  );
  final String id;
  final String name;
  final double latitude;
  final double longitude;
}
