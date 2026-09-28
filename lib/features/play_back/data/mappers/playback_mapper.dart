import '../../domain/entities/playback_point.dart';
import '../../domain/entities/playback_segment.dart';
import '../models/playback_point_model.dart';
import '../models/playback_segment_model.dart';

abstract final class PlaybackMapper {
  static PlaybackPoint point(PlaybackPointModel model) => PlaybackPoint(
    latitude: model.latitude,
    longitude: model.longitude,
    recordedAt: model.recordedAt,
    headingDegrees: model.headingDegrees,
    speedKph: model.speedKph,
  );
  static PlaybackSegment segment(PlaybackSegmentModel model) => PlaybackSegment(
    startedAt: model.startedAt,
    endedAt: model.endedAt,
    distanceKm: model.distanceKm,
    durationMinutes: model.durationMinutes,
    maxSpeedKph: model.maxSpeedKph,
    startPlace: model.startPlace,
    endPlace: model.endPlace,
    status: model.status,
  );
}
