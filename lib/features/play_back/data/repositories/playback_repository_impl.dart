import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/playback_point.dart';
import '../../domain/entities/playback_segment.dart';
import '../../domain/repositories/playback_repository.dart';
import '../datasources/playback_datasource.dart';
import '../mappers/playback_mapper.dart';

@LazySingleton(as: PlaybackRepository)
class PlaybackRepositoryImpl implements PlaybackRepository {
  const PlaybackRepositoryImpl(this._dataSource);

  final PlaybackDataSource _dataSource;

  @override
  Future<Either<Failure, List<PlaybackSegment>>> getSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final models = await _dataSource.getSegments(
        assetId: assetId,
        from: from,
        to: to,
      );
      return Right(models.map(PlaybackMapper.segment).toList(growable: false));
    } on AppException catch (error) {
      return Left(FailureMapper.fromException(error));
    } catch (error, stack) {
      return Left(UnknownFailure(message: error.toString(), stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, List<PlaybackPoint>>> getRoute({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final models = await _dataSource.getRoute(
        assetId: assetId,
        from: from,
        to: to,
      );
      return Right(models.map(PlaybackMapper.point).toList(growable: false));
    } on AppException catch (error) {
      return Left(FailureMapper.fromException(error));
    } catch (error, stack) {
      return Left(UnknownFailure(message: error.toString(), stackTrace: stack));
    }
  }
}
