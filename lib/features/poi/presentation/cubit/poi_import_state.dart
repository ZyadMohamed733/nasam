import '../../domain/entities/poi_import_row.dart';

/// The step a bulk upload is on.
sealed class PoiImportStep {
  const PoiImportStep();

  /// Zero-based, as the stepper counts.
  int get index;
}

final class PoiImportUploadStep extends PoiImportStep {
  const PoiImportUploadStep();
  @override
  int get index => 0;
}

final class PoiImportValidationStep extends PoiImportStep {
  const PoiImportValidationStep();
  @override
  int get index => 1;
}

final class PoiImportPreviewStep extends PoiImportStep {
  const PoiImportPreviewStep();
  @override
  int get index => 2;
}

final class PoiImportConfirmStep extends PoiImportStep {
  const PoiImportConfirmStep(this.summary);
  final PoiImportSummary summary;
  @override
  int get index => 3;
}

/// What an import did, for the confirm step's tiles.
class PoiImportSummary {
  const PoiImportSummary({
    required this.total,
    required this.imported,
    required this.failed,
    required this.duplicates,
  });

  final int total, imported, failed, duplicates;
}

/// The chosen workbook, as the upload step shows it.
class PoiImportFile {
  const PoiImportFile({required this.name, required this.size});
  final String name;

  /// Bytes; 0 when the picker did not say.
  final int size;
}

/// A bulk upload: its step, the file, the validated rows and how they are
/// being browsed. The filter, page and counts the screens show are derived
/// here, never in a widget.
class PoiImportState {
  const PoiImportState({
    this.step = const PoiImportUploadStep(),
    this.busy = false,
    this.error = false,
    this.file,
    this.rows = const [],
    this.filter,
    this.page = 0,
  });

  final PoiImportStep step;
  final bool busy, error;
  final PoiImportFile? file;
  final List<PoiImportRow> rows;

  /// Validation's filter; null shows every row.
  final PoiRowStatus? filter;

  /// Zero-based, within [visibleRows].
  final int page;

  static const int pageSize = 10;

  /// Rows with [status], or every row for null.
  int count(PoiRowStatus? status) => status == null
      ? rows.length
      : rows.where((r) => r.status == status).length;

  List<PoiImportRow> get validRows =>
      rows.where((r) => r.status == PoiRowStatus.valid).toList();

  /// What the table lists: the filtered rows on validation, the valid ones
  /// on preview.
  List<PoiImportRow> get visibleRows => switch (step) {
    PoiImportPreviewStep() => validRows,
    _ => filter == null ? rows : rows.where((r) => r.status == filter).toList(),
  };

  int get pageCount =>
      visibleRows.isEmpty ? 1 : (visibleRows.length / pageSize).ceil();

  List<PoiImportRow> get pageRows =>
      visibleRows.skip(page * pageSize).take(pageSize).toList();

  PoiImportState copyWith({
    PoiImportStep? step,
    bool? busy,
    bool? error,
    PoiImportFile? file,
    bool clearFile = false,
    List<PoiImportRow>? rows,
    PoiRowStatus? filter,
    bool clearFilter = false,
    int? page,
  }) => PoiImportState(
    step: step ?? this.step,
    busy: busy ?? this.busy,
    error: error ?? this.error,
    file: clearFile ? null : file ?? this.file,
    rows: rows ?? this.rows,
    filter: clearFilter ? null : filter ?? this.filter,
    page: page ?? this.page,
  );
}
