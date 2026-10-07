import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracked_asset.dart';
import '../repositories/tracking_repository.dart';
class GetTrackedAssetUseCase {
  const GetTrackedAssetUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, TrackedAsset>> call(String assetId) =>
      _repository.getTrackedAsset(assetId);
}
