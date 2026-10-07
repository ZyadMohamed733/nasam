import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/usecases/poi_operations.dart';

enum PoiEditorStatus {
  initial,
  loading,
  ready,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class PoiEditorState {
  const PoiEditorState({
    this.status = PoiEditorStatus.initial,
    this.point,
    this.failure,
  });
  final PoiEditorStatus status;
  final PointOfInterest? point;
  final Failure? failure;
  bool get busy =>
      status == PoiEditorStatus.loading ||
      status == PoiEditorStatus.saving ||
      status == PoiEditorStatus.deleting;
}
class PoiEditorCubit extends Cubit<PoiEditorState> {
  PoiEditorCubit(this._get, this._save, this._delete)
    : super(const PoiEditorState());
  final GetPointOfInterestUseCase _get;
  final SavePointOfInterestUseCase _save;
  final DeletePointOfInterestUseCase _delete;
  Future<void> load(String id) async {
    if (state.busy) return;
    emit(PoiEditorState(status: PoiEditorStatus.loading, point: state.point));
    final result = await _get(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PoiEditorState(
          status: PoiEditorStatus.failure,
          point: state.point,
          failure: failure,
        ),
      ),
      (point) =>
          emit(PoiEditorState(status: PoiEditorStatus.ready, point: point)),
    );
  }

  Future<void> save(PoiDraft draft, {String? id}) async {
    if (state.busy || state.status == PoiEditorStatus.saved) return;
    emit(PoiEditorState(status: PoiEditorStatus.saving, point: state.point));
    final result = await _save(draft, id: id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PoiEditorState(
          status: PoiEditorStatus.failure,
          point: state.point,
          failure: failure,
        ),
      ),
      (point) =>
          emit(PoiEditorState(status: PoiEditorStatus.saved, point: point)),
    );
  }

  Future<void> delete(String id) async {
    if (state.busy || state.status == PoiEditorStatus.deleted) return;
    emit(PoiEditorState(status: PoiEditorStatus.deleting, point: state.point));
    final result = await _delete(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PoiEditorState(
          status: PoiEditorStatus.failure,
          point: state.point,
          failure: failure,
        ),
      ),
      (_) => emit(const PoiEditorState(status: PoiEditorStatus.deleted)),
    );
  }
}
