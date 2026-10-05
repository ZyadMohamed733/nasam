import 'package:flutter/foundation.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';

import '../../../../core/errors/failures.dart';

sealed class HistoryAlertState{
  const HistoryAlertState();
}

class HistoryAlertLoading extends HistoryAlertState{
  const HistoryAlertLoading();
  @override
  bool operator ==(Object other) => other is HistoryAlertLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}
class HistoryAlertLoaded extends HistoryAlertState {
  final List<HistoryAlertEntity> historyAlertDataList;
  final DateTime? selectedDate;
  const HistoryAlertLoaded({
    required this.historyAlertDataList,
    this.selectedDate,
  });

  @override
  bool operator ==(Object other) =>
      other is HistoryAlertLoaded &&
          listEquals(other.historyAlertDataList, historyAlertDataList) &&
          other.selectedDate == selectedDate;

  @override
  int get hashCode => Object.hash(Object.hashAll(historyAlertDataList), selectedDate);
}
class HistoryAlertDetailLoaded extends HistoryAlertState {
  final HistoryAlertDetailsEntity detailsEntity;
  const HistoryAlertDetailLoaded({required this.detailsEntity});

  @override
  bool operator ==(Object other) =>
      other is HistoryAlertDetailLoaded && other.detailsEntity == detailsEntity;

  @override
  int get hashCode => detailsEntity.hashCode;
}
final class HistoryAlertFailure extends HistoryAlertState {
  const HistoryAlertFailure(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is HistoryAlertFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(HistoryAlertFailure, failure);
}
