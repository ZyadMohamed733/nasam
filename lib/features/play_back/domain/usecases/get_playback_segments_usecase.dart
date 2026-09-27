import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/playback_segment.dart';
import '../repositories/playback_repository.dart';

@lazySingleton
class GetPlaybackSegmentsUseCase {
  const GetPlaybackSegmentsUseCase(this._repository);
  final PlaybackRepository _repository;

  Future<Either<Failure, List<PlaybackSegment>>> call({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) => _repository.getSegments(assetId: assetId, from: from, to: to);
}
