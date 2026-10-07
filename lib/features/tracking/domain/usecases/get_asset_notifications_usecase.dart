import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracked_asset_details.dart';
import '../repositories/tracking_repository.dart';
class GetAssetNotificationsUseCase {
  const GetAssetNotificationsUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, List<TrackedAssetNotification>>> call(
    String assetId,
  ) => _repository.getAssetNotifications(assetId);
}
