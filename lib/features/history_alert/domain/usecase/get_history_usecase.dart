
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/repositories/history_alert_repository.dart';

@lazySingleton
class GetHistoryUseCase {
  final HistoryAlertRepository _repository;
    GetHistoryUseCase(this._repository);

    Future<Either<Failure,List<HistoryAlertEntity>>> getHistoryAlert() => _repository.getHistoryAlert();
}
