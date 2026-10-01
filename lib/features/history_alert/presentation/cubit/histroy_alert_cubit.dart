import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/hsitory_alert_state.dart';
@injectable
class HistoryAlertCubit extends Cubit<HistoryAlertState> {
  final GetHistoryUseCase _getHistoryUseCase;
  final GetHistoryDetailsUseCase _detailsUseCase;

  HistoryAlertCubit(this._getHistoryUseCase, this._detailsUseCase)
    : super(const HistoryAlertLoading());

  Future<void> getHistoryAlertData() async {
    final result = await _getHistoryUseCase.getHistoryAlert();

    result.fold((failure) {
      emit(HistoryAlertFailure(failure));
    }, (historyList) {
      emit(HistoryAlertLoaded(historyAlertDataList: historyList));
    });
  }

  void updateDateFilter(DateTime? selectedDate) {
    final current = state;
    if (current is! HistoryAlertLoaded) return;
    emit(
      HistoryAlertLoaded(
        historyAlertDataList: current.historyAlertDataList,
        selectedDate: selectedDate,
      ),
    );
  }

  Future<void> getHistoryAlertDetails() async {
    final result = await _detailsUseCase.getHistoryAlertDetails();

    result.fold((failure) {
      emit(HistoryAlertFailure(failure));
    }, (historyDetails) {
      emit(HistoryAlertDetailLoaded(detailsEntity: historyDetails));
    });
  }
}
