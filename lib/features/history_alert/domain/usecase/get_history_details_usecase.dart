import 'package:dartz/dartz.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/history_alert_repository.dart';
class GetHistoryDetailsUseCase {
  final HistoryAlertRepository _repository;
  GetHistoryDetailsUseCase(this._repository);

  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  }) => _repository.getHistoryAlertDetails(alertId: alertId);
}
