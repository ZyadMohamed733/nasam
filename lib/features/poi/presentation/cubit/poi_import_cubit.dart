import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/poi_import_row.dart';
import '../../domain/repositories/poi_files.dart';
import '../../domain/usecases/get_points_of_interest_usecase.dart';
import '../../domain/usecases/poi_operations.dart';

class PoiImportState {
  const PoiImportState({
    this.step = 0,
    this.busy = false,
    this.fileName,
    this.rows = const [],
    this.error = false,
    this.imported = 0,
  });
  final int step;
  final bool busy, error;
  final String? fileName;
  final List<PoiImportRow> rows;
  final int imported;
  List<PoiImportRow> get valid =>
      rows.where((r) => r.status == PoiRowStatus.valid).toList();
}

@injectable
class PoiImportCubit extends Cubit<PoiImportState> {
  PoiImportCubit(this._files, this._get, this._import)
    : super(const PoiImportState());
  final PoiFiles _files;
  final GetPointsOfInterestUseCase _get;
  final ImportPointsOfInterestUseCase _import;
  List<List<String>>? _raw;
  Future<void> pick() async {
    if (state.busy) return;
    final before = state;
    emit(
      PoiImportState(busy: true, fileName: before.fileName, rows: before.rows),
    );
    try {
      final file = await _files.pick();
      if (isClosed) return;
      if (file == null) {
        emit(before);
        return;
      }
      _raw = file.rows;
      emit(PoiImportState(fileName: file.name));
    } catch (_) {
      if (!isClosed) {
        emit(
          PoiImportState(
            fileName: before.fileName,
            rows: before.rows,
            error: true,
          ),
        );
      }
    }
  }

  Future<void> validate() async {
    if (state.busy || _raw == null) return;
    emit(PoiImportState(busy: true, fileName: state.fileName));
    try {
      final result = await _get();
      if (isClosed) return;
      result.fold(
        (_) => emit(PoiImportState(fileName: state.fileName, error: true)),
        (existing) {
          final rows = PoiImportValidation.validate(_raw!, existing);
          emit(
            PoiImportState(
              step: 1,
              fileName: state.fileName,
              rows: List.unmodifiable(rows),
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(PoiImportState(fileName: state.fileName, error: true));
      }
    }
  }

  void preview() {
    if (!state.busy && state.step == 1 && state.valid.isNotEmpty) {
      emit(PoiImportState(step: 2, fileName: state.fileName, rows: state.rows));
    }
  }

  void previous() {
    if (!state.busy && state.step > 0 && state.step < 3) {
      emit(
        PoiImportState(
          step: state.step - 1,
          fileName: state.fileName,
          rows: state.rows,
        ),
      );
    }
  }

  Future<void> confirm() async {
    if (state.busy || state.step != 2 || state.valid.isEmpty) return;
    emit(
      PoiImportState(
        step: 2,
        busy: true,
        fileName: state.fileName,
        rows: state.rows,
      ),
    );
    final result = await _import(state.valid.map((r) => r.draft!).toList());
    if (isClosed) return;
    result.fold(
      (_) => emit(
        PoiImportState(
          step: 2,
          fileName: state.fileName,
          rows: state.rows,
          error: true,
        ),
      ),
      (count) => emit(
        PoiImportState(
          step: 3,
          fileName: state.fileName,
          rows: state.rows,
          imported: count,
        ),
      ),
    );
  }

  Future<bool> saveTemplate() => _files.save();
}
