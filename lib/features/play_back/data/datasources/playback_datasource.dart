import '../models/playback_segment_model.dart';

abstract interface class PlaybackDataSource {
  Future<List<PlaybackSegmentModel>> getSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  });
}
