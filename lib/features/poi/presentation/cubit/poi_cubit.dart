import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/poi_files.dart';
import '../../domain/usecases/get_points_of_interest_usecase.dart';
import '../../domain/usecases/poi_operations.dart';
import 'poi_state.dart';

export 'poi_state.dart';
class PoiCubit extends Cubit<PoiState> {
  PoiCubit(
    this._getPoints,
    this._files,
    this._delete,
    WatchPoiChangesUseCase watch,
  ) : super(const PoiState()) {
    _changes = watch().listen((_) {
      if (state.status == PoiStatus.loading) {
        _refreshPending = true;
      } else {
        unawaited(load());
      }
    });
  }
  late final StreamSubscription<void> _changes;
  bool _refreshPending = false;
  @override
  Future<void> close() async {
    await _changes.cancel();
    await super.close();
  }

  final GetPointsOfInterestUseCase _getPoints;
  final PoiFiles _files;
  final DeletePointOfInterestUseCase _delete;
  bool _deleting = false;
  Future<bool> delete(String id) async {
    if (_deleting) return false;
    _deleting = true;
    try {
      final result = await _delete(id);
      if (isClosed) return false;
      if (result.isLeft()) return false;
      await load();
      return true;
    } finally {
      _deleting = false;
    }
  }

  Future<bool> export() => _files.save(points: state.points);
  Future<void> load() async {
    if (state.status == PoiStatus.loading) return;
    emit(
      PoiState(
        status: PoiStatus.loading,
        points: state.points,
        query: state.query,
        selectedId: state.selectedId,
      ),
    );
    final result = await _getPoints();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PoiState(
          status: PoiStatus.failure,
          points: state.points,
          query: state.query,
          selectedId: state.selectedId,
          failure: failure,
        ),
      ),
      (points) => emit(
        PoiState(
          status: PoiStatus.loaded,
          points: List.unmodifiable(points),
          query: state.query,
          selectedId: points.any((p) => p.id == state.selectedId)
              ? state.selectedId
              : null,
        ),
      ),
    );
    if (_refreshPending && !isClosed) {
      _refreshPending = false;
      await load();
    }
  }

  void search(String query) => emit(
    PoiState(
      status: state.status,
      points: state.points,
      query: query,
      selectedId: state.selectedId,
      failure: state.failure,
    ),
  );
  void select(String id) {
    if (!state.points.any((p) => p.id == id)) return;
    emit(
      PoiState(
        status: state.status,
        points: state.points,
        query: state.query,
        selectedId: id,
        failure: state.failure,
      ),
    );
  }
}
