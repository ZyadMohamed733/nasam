/// One leg of an asset's journey, as the playback screen lists them.
class TrackingPlaybackSegment {
  const TrackingPlaybackSegment({
    required this.startedAt,
    required this.endedAt,
    required this.distanceKm,
    required this.durationMinutes,
    required this.maxSpeedKph,
    required this.startPlace,
    required this.endPlace,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceKm;
  final int durationMinutes;
  final int maxSpeedKph;

  /// Where the leg began and ended. Place names are data, not UI copy — they
  /// were ARB keys, which meant every asset in the fleet appeared to start at
  /// the same airport.
  final String startPlace;
  final String endPlace;
}
