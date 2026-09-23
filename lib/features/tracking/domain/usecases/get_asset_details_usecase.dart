import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracked_asset_details.dart';
import '../repositories/tracking_repository.dart';

@lazySingleton
class GetAssetDetailsUseCase {
  const GetAssetDetailsUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, TrackedAssetDetails>> call(String assetId) =>
      _repository.getAssetDetails(assetId);
}
