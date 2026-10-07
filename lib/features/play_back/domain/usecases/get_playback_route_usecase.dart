import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/playback_point.dart';
import '../repositories/playback_repository.dart';
class GetPlaybackRouteUseCase {
  const GetPlaybackRouteUseCase(this._repository);
  final PlaybackRepository _repository;
  Future<Either<Failure, List<PlaybackPoint>>> call({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) => _repository.getRoute(assetId: assetId, from: from, to: to);
}
