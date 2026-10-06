import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/data/datasources/history_alert_datasource.dart';

import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';

import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../domain/repositories/history_alert_repository.dart';
import '../mappers/history_mapper.dart';

@LazySingleton(as: HistoryAlertRepository)
class HistoryRepoImpl implements HistoryAlertRepository {
  HistoryRepoImpl({required this.dataSource});

  final HistoryAlertDataSource dataSource;
  @override
  Future<Either<Failure, List<HistoryAlertEntity>>> getHistoryAlert() async {
    try {
      final models = await dataSource.getHistoryAlert();
      return Right(models.map(AlertMapper.alert).toList(growable: false));
    } on AppException catch (error) {
      return Left(FailureMapper.fromException(error));
    } catch (error, stack) {
      return Left(UnknownFailure(message: error.toString(), stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  }) async {
    try {
      final resultModel = await dataSource.getHistoryDetailed(alertId: alertId);
      final historyEntity = AlertMapper.details(resultModel);
      return Right(historyEntity);
    } catch (error, stack) {
      return Left(mapException(error, stack));
    }
  }

  Failure mapException(Object e, StackTrace stack) {
    if (e is AppException) {
      return FailureMapper.fromException(e);
    }
    return UnknownFailure(message: e.toString(), stackTrace: stack);
  }
}
