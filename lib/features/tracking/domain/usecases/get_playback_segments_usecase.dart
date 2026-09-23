import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracking_playback_segment.dart';
import '../repositories/tracking_repository.dart';

@lazySingleton
class GetPlaybackSegmentsUseCase {
  const GetPlaybackSegmentsUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, List<TrackingPlaybackSegment>>> call({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) => _repository.getPlaybackSegments(assetId: assetId, from: from, to: to);
}
