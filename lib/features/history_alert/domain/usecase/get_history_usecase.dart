import 'package:dartz/dartz.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/domain/repositories/history_alert_repository.dart';

import '../entities/alert_history_page.dart';

class GetHistoryUseCase {
  final HistoryAlertRepository _repository;
  GetHistoryUseCase(this._repository);

  Future<Either<Failure, AlertHistoryPage>> getHistoryAlert(
    AlertHistoryQuery query,
  ) => _repository.getHistoryAlert(query);
}
