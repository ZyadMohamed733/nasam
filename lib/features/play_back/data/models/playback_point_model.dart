class PlaybackPointModel {
  const PlaybackPointModel({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.headingDegrees,
    required this.speedKph,
  });
  factory PlaybackPointModel.fromJson(Map<String, dynamic> json) =>
      PlaybackPointModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        headingDegrees: (json['headingDegrees'] as num? ?? 0).toDouble(),
        speedKph: (json['speedKph'] as num? ?? 0).toDouble(),
      );
  final double latitude, longitude;
  final DateTime recordedAt;
  final double headingDegrees, speedKph;
}
