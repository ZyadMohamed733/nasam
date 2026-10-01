import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_data_table.dart';
import '../../../../../shared/widgets/app_pagination.dart';
import '../../../../../shared/widgets/app_status_chip.dart';
import '../../../domain/entities/poi_import_row.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_layout.dart';
import 'poi_import_status.dart';

/// The rows of the current page (`561:13806`) with their pagination under
/// them. Validation adds a reason column and outlines invalid rows.
///
/// Pagination answers touches across 48, so place this under a
/// `HitTargetScope` with room below it.
class PoiImportRowsTable extends StatelessWidget {
  const PoiImportRowsTable({
    super.key,
    required this.state,
    required this.withReason,
  });

  final PoiImportState state;
  final bool withReason;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cubit = context.read<PoiImportCubit>();
    final labels = [
      l.poiName,
      l.poiLatitude,
      l.poiLongitude,
      l.poiIcon,
      l.poiStatus,
      if (withReason) l.poiReason,
    ];
    final status = labels.indexOf(l.poiStatus);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDataTable(
          columns: PoiImportLayout.columns(
            labels,
            withReason
                ? PoiImportLayout.validationColumns
                : PoiImportLayout.previewColumns,
            sortable: status,
          ),
          rows: [for (final row in state.pageRows) _row(context, row, l)],
        ),
        AppPagination(
          page: state.page,
          pageCount: state.pageCount,
          totalLabel: l.poiTotalRecords(state.visibleRows.length),
          onPage: state.busy ? null : cubit.goToPage,
        ),
      ],
    );
  }

  AppDataRow _row(BuildContext context, PoiImportRow row, AppLocalizations l) {
    Widget text(String value) => AppDataTable.text(context, value);
    Widget ltr(String value) =>
        Directionality(textDirection: TextDirection.ltr, child: text(value));
    return AppDataRow(
      flagged: row.status == PoiRowStatus.invalid,
      cells: [
        text(row.name),
        ltr(row.latitude),
        ltr(row.longitude),
        text(row.iconName),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppStatusChip(
            tone: PoiImportStatus.tone(row.status),
            label: PoiImportStatus.label(row.status, l),
          ),
        ),
        if (withReason) text(PoiImportStatus.reason(row, l)),
      ],
    );
  }
}
