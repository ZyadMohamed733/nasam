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
      name.trim().isNotEmpty &&
      name.trim().length <= 200 &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      notes.length <= 2000;
}
