import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../domain/entities/poi_import_row.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_status.dart';

/// TEMPORARY: the pre-redesign Validation, Preview and Confirm bodies, kept
/// working on the new state until each step is rebuilt. Deleted once
/// Confirm is.
class PoiImportLegacySteps extends StatelessWidget {
  const PoiImportLegacySteps({super.key, required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cubit = context.read<PoiImportCubit>();
    final summary = switch (state.step) {
      PoiImportConfirmStep(:final summary) => summary,
      _ => null,
    };
    if (summary != null) {
      return Column(
        children: [
          Text(l.poiImportComplete),
          Text('${l.poiTotal}: ${summary.total}'),
          Text('${l.poiImported}: ${summary.imported}'),
          AppButton(
            label: l.poiShowPoints,
            variant: AppButtonVariant.tertiary,
            onPressed: () => context.pop(true),
          ),
        ],
      );
    }
    final validation = state.step is PoiImportValidationStep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(validation ? l.poiValidationTitle : l.poiPreviewTitle),
        if (validation)
          Wrap(
            spacing: 8,
            children: [
              for (final status in [null, ...PoiRowStatus.values])
                ChoiceChip(
                  selected: state.filter == status,
                  label: Text(
                    '${PoiImportStatus.label(status, l)} (${state.count(status)})',
                  ),
                  onSelected: (_) => cubit.filter(status),
                ),
            ],
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              for (final title in [l.poiName, l.poiLatitude, l.poiStatus])
                DataColumn(label: Text(title)),
            ],
            rows: [
              for (final row in state.pageRows)
                DataRow(
                  cells: [
                    DataCell(Text(row.name)),
                    DataCell(Text(row.latitude)),
                    DataCell(Text(PoiImportStatus.label(row.status, l))),
                  ],
                ),
            ],
          ),
        ),
        Text('${state.page + 1} / ${state.pageCount}'),
      ],
    );
  }
}
