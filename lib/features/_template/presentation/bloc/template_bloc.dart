import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_template_usecase.dart';
import 'template_event.dart';
import 'template_state.dart';

@injectable
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc(this._getTemplateUseCase)
    : super(const TemplateState.initial()) {
    on<LoadTemplate>(_onLoadTemplate);
  }

  final GetTemplateUseCase _getTemplateUseCase;

  Future<void> _onLoadTemplate(
    LoadTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateState.loading());
    final result = await _getTemplateUseCase(event.id);
    result.fold(
      (failure) => emit(TemplateState.failure(failure)),
      (entity) => emit(TemplateState.success(entity)),
    );
  }
}
