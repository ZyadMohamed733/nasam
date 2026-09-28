class PoiModel {
  const PoiModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.icon = 'location',
    this.notes = '',
  });
  factory PoiModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String;
    final latitude = (json['latitude'] as num).toDouble();
    final longitude = (json['longitude'] as num).toDouble();
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      throw const FormatException('Invalid POI identity or coordinates');
    }
    return PoiModel(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      icon: json['icon'] as String? ?? 'location',
      notes: json['notes'] as String? ?? '',
    );
  }
  final String icon;
  final String notes;
  final String id;
  final String name;
  final double latitude;
  final double longitude;
}
