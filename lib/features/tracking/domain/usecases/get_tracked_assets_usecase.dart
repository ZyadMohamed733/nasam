import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracked_asset.dart';
import '../repositories/tracking_repository.dart';
class GetTrackedAssetsUseCase {
  const GetTrackedAssetsUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, List<TrackedAsset>>> call() =>
      _repository.getTrackedAssets();
}
