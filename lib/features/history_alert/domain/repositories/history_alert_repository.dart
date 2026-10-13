import 'package:dartz/dartz.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../entities/alert_history_page.dart';

abstract interface class HistoryAlertRepository {
  Future<Either<Failure, AlertHistoryPage>> getHistoryAlert(
    AlertHistoryQuery query,
  );
  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  });
}
