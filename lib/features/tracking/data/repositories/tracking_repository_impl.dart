import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../../domain/entities/tracking_playback_segment.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_dummy_datasource.dart';

@LazySingleton(as: TrackingRepository)
class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl(this._dataSource);

  final TrackingDataSource _dataSource;

  @override
  Future<Either<Failure, List<TrackingVehicle>>> getVehicles() =>
      _guard(_dataSource.getVehicles);

  @override
  Future<Either<Failure, List<TrackedAsset>>> getTrackedAssets() =>
      _guard(_dataSource.getTrackedAssets);

  @override
  Future<Either<Failure, TrackedAssetDetails>> getAssetDetails(
    String assetId,
  ) => _guard(() => _dataSource.getAssetDetails(assetId));

  @override
  Future<Either<Failure, List<TrackedAssetNotification>>> getAssetNotifications(
    String assetId,
  ) => _guard(() => _dataSource.getAssetNotifications(assetId));

  @override
  Future<Either<Failure, List<TrackingPlaybackSegment>>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) => _guard(
    () => _dataSource.getPlaybackSegments(
      assetId: assetId,
      from: from,
      to: to,
    ),
  );

  /// No cache fallback anywhere here, deliberately. Tracking answers "where is
  /// it now"; a stale position presented as current is worse than an error.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on AppException catch (e) {
      return Left(FailureMapper.fromException(e));
    } catch (e, stack) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: stack));
    }
  }
}
