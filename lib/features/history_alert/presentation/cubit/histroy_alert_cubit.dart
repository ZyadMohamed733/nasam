import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/hsitory_alert_state.dart';

/// One alert's details. The list has its own cubit,
/// `AlertHistoryListCubit`.
class HistoryAlertCubit extends Cubit<HistoryAlertState> {
  final GetHistoryDetailsUseCase _detailsUseCase;

  HistoryAlertCubit(this._detailsUseCase) : super(const HistoryAlertLoading());

  Future<void> getHistoryAlertDetails({required String alertId}) async {
    emit(const HistoryAlertLoading());
    final result = await _detailsUseCase.getHistoryAlertDetails(
      alertId: alertId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(HistoryAlertFailure(failure)),
      (details) => emit(HistoryAlertDetailLoaded(detailsEntity: details)),
    );
  }
}
