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
import '../datasources/tracking_datasource.dart';
import '../mappers/tracking_mapper.dart';

@LazySingleton(as: TrackingRepository)
class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl(this._dataSource);

  final TrackingDataSource _dataSource;

  @override
  Future<Either<Failure, List<TrackingVehicle>>> getVehicles() => _guard(
    () async => (await _dataSource.getVehicles())
        .map(TrackingMapper.vehicle)
        .toList(growable: false),
  );

  @override
  Future<Either<Failure, List<TrackedAsset>>> getTrackedAssets() => _guard(
    () async => (await _dataSource.getTrackedAssets())
        .map(TrackingMapper.asset)
        .toList(growable: false),
  );

  @override
  Future<Either<Failure, TrackedAssetDetails>> getAssetDetails(
    String assetId,
  ) => _guard(
    () async => TrackingMapper.details(
      await _dataSource.getAssetDetails(assetId),
    ),
  );

  @override
  Future<Either<Failure, List<TrackedAssetNotification>>> getAssetNotifications(
    String assetId,
  ) => _guard(
    () async => (await _dataSource.getAssetNotifications(assetId))
        .map(TrackingMapper.notification)
        .toList(growable: false),
  );

  @override
  Future<Either<Failure, List<TrackingPlaybackSegment>>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) => _guard(
    () async => (await _dataSource.getPlaybackSegments(
      assetId: assetId,
      from: from,
      to: to,
    )).map(TrackingMapper.segment).toList(growable: false),
  );

  /// Everything that can go wrong between the wire and the entity lands here:
  /// an AppException from the source maps to its Failure, and anything else —
  /// a malformed response, an unknown enum value from the mapper — becomes an
  /// UnknownFailure instead of escaping into a widget.
  ///
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
