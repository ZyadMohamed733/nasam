import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/poi_import_row.dart';
import '../../domain/repositories/poi_files.dart';
import '../../domain/usecases/get_points_of_interest_usecase.dart';
import '../../domain/usecases/poi_operations.dart';
import 'poi_import_state.dart';

export 'poi_import_state.dart';

/// Drives a bulk upload: pick a workbook, validate its rows against the
/// saved points, browse and preview them, then import the valid ones once.
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
    emit(before.copyWith(busy: true, error: false));
    try {
      final file = await _files.pick();
      if (isClosed) return;
      if (file == null) {
        emit(before);
        return;
      }
      _raw = file.rows;
      emit(
        PoiImportState(
          file: PoiImportFile(name: file.name, size: file.size),
        ),
      );
    } catch (_) {
      if (!isClosed) emit(before.copyWith(busy: false, error: true));
    }
  }

  /// Drops the chosen workbook, back to an empty upload step.
  void clearFile() {
    if (state.busy || state.step is! PoiImportUploadStep) return;
    _raw = null;
    emit(const PoiImportState());
  }

  Future<void> validate() async {
    if (state.busy || _raw == null) return;
    emit(state.copyWith(busy: true, error: false));
    try {
      final result = await _get();
      if (isClosed) return;
      result.fold(
        (_) => emit(state.copyWith(busy: false, error: true)),
        (existing) => emit(
          PoiImportState(
            step: const PoiImportValidationStep(),
            file: state.file,
            rows: List.unmodifiable(
              PoiImportValidation.validate(_raw!, existing),
            ),
          ),
        ),
      );
    } catch (_) {
      if (!isClosed) emit(state.copyWith(busy: false, error: true));
    }
  }

  /// Shows only rows with [status] on validation; null shows them all.
  void filter(PoiRowStatus? status) {
    if (state.busy || state.step is! PoiImportValidationStep) return;
    emit(state.copyWith(filter: status, clearFilter: status == null, page: 0));
  }

  void goToPage(int page) {
    if (state.busy) return;
    emit(state.copyWith(page: page.clamp(0, state.pageCount - 1)));
  }

  void preview() {
    if (!state.busy &&
        state.step is PoiImportValidationStep &&
        state.validRows.isNotEmpty) {
      emit(
        state.copyWith(
          step: const PoiImportPreviewStep(),
          clearFilter: true,
          page: 0,
          error: false,
        ),
      );
    }
  }

  void previous() {
    if (state.busy) return;
    final step = switch (state.step) {
      PoiImportPreviewStep() => const PoiImportValidationStep(),
      PoiImportValidationStep() => const PoiImportUploadStep(),
      _ => null,
    };
    if (step == null) return;
    emit(state.copyWith(step: step, clearFilter: true, page: 0, error: false));
  }

  Future<void> confirm() async {
    if (state.busy ||
        state.step is! PoiImportPreviewStep ||
        state.validRows.isEmpty) {
      return;
    }
    emit(state.copyWith(busy: true, error: false));
    final valid = state.validRows;
    final result = await _import(valid.map((r) => r.draft!).toList());
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(busy: false, error: true)),
      (imported) => emit(
        state.copyWith(
          busy: false,
          step: PoiImportConfirmStep(
            PoiImportSummary(
              total: state.rows.length,
              imported: imported,
              failed:
                  state.count(PoiRowStatus.invalid) + valid.length - imported,
              duplicates: state.count(PoiRowStatus.duplicate),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> saveTemplate() => _files.save();
}
