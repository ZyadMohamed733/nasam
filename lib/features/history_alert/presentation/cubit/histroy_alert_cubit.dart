import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/hsitory_alert_state.dart';

class HistoryAlertCubit extends Cubit<HistoryAlertState> {
  final GetHistoryUseCase _getHistoryUseCase;
  final GetHistoryDetailsUseCase _detailsUseCase;

  HistoryAlertCubit(this._getHistoryUseCase, this._detailsUseCase)
    : super(const HistoryAlertLoading());

  Future<void> getHistoryAlertData() async {
    emit(const HistoryAlertLoading());
    final result = await _getHistoryUseCase.getHistoryAlert();

    result.fold(
      (failure) {
        emit(HistoryAlertFailure(failure));
      },
      (historyList) {
        emit(HistoryAlertLoaded(historyAlertDataList: historyList));
      },
    );
  }

  /// Narrows the loaded list. [AlertHistoryFilter.none] is Reset.
  void applyFilter(AlertHistoryFilter filter) {
    final current = state;
    if (current is! HistoryAlertLoaded) return;
    emit(
      HistoryAlertLoaded(
        historyAlertDataList: current.historyAlertDataList,
        filter: filter,
      ),
    );
  }

  Future<void> getHistoryAlertDetails({required String alertId}) async {
    emit(const HistoryAlertLoading());
    final result = await _detailsUseCase.getHistoryAlertDetails(
      alertId: alertId,
    );

    result.fold(
      (failure) {
        emit(HistoryAlertFailure(failure));
      },
      (historyDetails) {
        emit(HistoryAlertDetailLoaded(detailsEntity: historyDetails));
      },
    );
  }
}
