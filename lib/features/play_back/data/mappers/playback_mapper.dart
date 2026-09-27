import '../../domain/entities/playback_segment.dart';
import '../models/playback_segment_model.dart';

abstract final class PlaybackMapper {
  static PlaybackSegment segment(PlaybackSegmentModel model) =>
      PlaybackSegment(
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
