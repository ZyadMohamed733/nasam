import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/alert_history_page.dart';
import '../../domain/entities/history_details.dart';
import '../../domain/repositories/history_alert_repository.dart';
import '../datasources/history_alert_datasource.dart';
import '../mappers/history_mapper.dart';

/// No cache: Alert History is a live log the user filters and pages through,
/// and a stale page would show alerts as current that are not.
class HistoryRepoImpl implements HistoryAlertRepository {
  HistoryRepoImpl({required this.dataSource});

  final HistoryAlertDataSource dataSource;

  @override
  Future<Either<Failure, AlertHistoryPage>> getHistoryAlert(
    AlertHistoryQuery query,
  ) => _guard(
    () async => AlertMapper.page(await dataSource.getHistoryAlert(query)),
  );

  @override
  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  }) => _guard(
    () async => AlertMapper.details(
      await dataSource.getHistoryDetailed(alertId: alertId),
    ),
  );

  static Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on AppException catch (error) {
      return Left(FailureMapper.fromException(error));
    } catch (error, stack) {
      return Left(UnknownFailure(message: error.toString(), stackTrace: stack));
    }
  }
}
