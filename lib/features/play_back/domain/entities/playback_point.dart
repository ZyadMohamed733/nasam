class PlaybackPoint {
  const PlaybackPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.headingDegrees,
    required this.speedKph,
  });
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double headingDegrees;
  final double speedKph;
}
