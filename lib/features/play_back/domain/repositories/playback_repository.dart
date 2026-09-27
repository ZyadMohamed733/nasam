import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/playback_segment.dart';

abstract interface class PlaybackRepository {
  Future<Either<Failure, List<PlaybackSegment>>> getSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  });
}
