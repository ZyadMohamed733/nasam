import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracked_asset.dart';
import '../entities/tracked_asset_details.dart';
import '../entities/tracking_playback_segment.dart';
import '../entities/tracking_vehicle.dart';

abstract interface class TrackingRepository {
  /// Map positions. Separate from [getTrackedAssets] because the map refreshes
  /// far more often than the list and does not want the fleet metadata.
  Future<Either<Failure, List<TrackingVehicle>>> getVehicles();

  Future<Either<Failure, List<TrackedAsset>>> getTrackedAssets();

  Future<Either<Failure, TrackedAssetDetails>> getAssetDetails(String assetId);

  Future<Either<Failure, List<TrackedAssetNotification>>> getAssetNotifications(
    String assetId,
  );

  Future<Either<Failure, List<TrackingPlaybackSegment>>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  });
}
