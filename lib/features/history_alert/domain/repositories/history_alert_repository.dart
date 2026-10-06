import 'package:dartz/dartz.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../entities/history_alert.dart';

abstract interface class HistoryAlertRepository {
  Future<Either<Failure, List<HistoryAlertEntity>>> getHistoryAlert();
  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  });
}
