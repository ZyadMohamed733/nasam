import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_status_chip.dart';
import '../../../../../shared/widgets/hit_target.dart';
import '../../../domain/entities/poi_import_row.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_layout.dart';
import 'poi_import_rows_table.dart';
import 'poi_import_status.dart';
import 'poi_import_title.dart';

/// Step 2, Validation (`561:13773`): the title naming the file, the status
/// filters with their counts, the rows of the current page with their
/// reasons, and how many will and will not be imported.
class PoiImportValidationView extends StatelessWidget {
  const PoiImportValidationView({super.key, required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cubit = context.read<PoiImportCubit>();
    return HitTargetScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PoiImportTitle(
            title: l.poiValidationTitle,
            description: l.poiValidationDescription(
              // The file name reads left to right inside Arabic.
              '\u2066${state.file?.name ?? ''}\u2069',
            ),
          ),
          const SizedBox(height: PoiImportLayout.titleGap),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              vertical: PoiImportLayout.chipRowPadding,
            ),
            child: Row(
              children: [
                for (final status in [null, ...PoiRowStatus.values]) ...[
                  if (status != null)
                    const SizedBox(width: PoiImportLayout.chipGap),
                  AppStatusChip(
                    key: ValueKey('poi-import-filter-${status?.name ?? 'all'}'),
                    tone: PoiImportStatus.tone(status),
                    label: PoiImportStatus.label(status, l),
                    count: state.count(status),
                    selected: state.filter == status,
                    onTap: state.busy ? null : () => cubit.filter(status),
                  ),
                ],
              ],
            ),
          ),
          PoiImportRowsTable(state: state, withReason: true),
          Text(
            l.poiValidationSummary(
              state.count(PoiRowStatus.valid),
              state.rows.length - state.count(PoiRowStatus.valid),
            ),
            style: AppTextStyles.bodySR20.copyWith(
              color: context.semanticColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
