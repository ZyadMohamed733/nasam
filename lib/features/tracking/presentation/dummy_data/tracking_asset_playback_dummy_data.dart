class TrackingAssetPlaybackSegment {
  const TrackingAssetPlaybackSegment({
    required this.startedAt,
    required this.endedAt,
    required this.distanceKm,
    required this.durationMinutes,
    required this.maxSpeedKph,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceKm;
  final int durationMinutes;
  final int maxSpeedKph;
}

abstract final class TrackingAssetPlaybackDummyData {
  static final segments = _createSegments();

  static List<TrackingAssetPlaybackSegment> _createSegments() {
    final now = DateTime.now();
    return List<TrackingAssetPlaybackSegment>.generate(6, (index) {
      final end = DateTime(now.year, now.month, now.day, 18 - (index * 2));
      final start = end.subtract(Duration(minutes: 30 + (index * 7)));
      return TrackingAssetPlaybackSegment(
        startedAt: start,
        endedAt: end,
        distanceKm: 3.2 + index * .8,
        durationMinutes: 30 + index * 7,
        maxSpeedKph: 42 + index * 5,
      );
    });
  }
}
