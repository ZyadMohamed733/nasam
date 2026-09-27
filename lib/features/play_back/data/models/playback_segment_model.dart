/// Wire shape of one entry in `GET /tracking/assets/:id/playback`.
class PlaybackSegmentModel {
  const PlaybackSegmentModel({
    required this.startedAt,
    required this.endedAt,
    required this.distanceKm,
    required this.durationMinutes,
    required this.maxSpeedKph,
    required this.startPlace,
    required this.endPlace,
    required this.status,
  });

  factory PlaybackSegmentModel.fromJson(Map<String, dynamic> json) =>
      PlaybackSegmentModel(
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        maxSpeedKph: (json['maxSpeedKph'] as num).toInt(),
        startPlace: json['startPlace'] as String? ?? '',
        endPlace: json['endPlace'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );

  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceKm;
  final int durationMinutes;
  final int maxSpeedKph;
  final String startPlace;
  final String endPlace;
  final String status;
}
