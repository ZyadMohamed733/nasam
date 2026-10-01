import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/hit_target.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_layout.dart';
import 'poi_import_rows_table.dart';
import 'poi_import_title.dart';

/// Step 3, Preview (`561:16321`): the valid rows only, a page at a time,
/// and the note that only they will be imported.
class PoiImportPreviewView extends StatelessWidget {
  const PoiImportPreviewView({super.key, required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return HitTargetScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PoiImportTitle(
            title: l.poiPreviewTitle,
            description: l.poiPreviewDescription,
          ),
          const SizedBox(height: PoiImportLayout.previewTableGap),
          PoiImportRowsTable(state: state, withReason: false),
          Text(
            l.poiValidOnly,
            style: AppTextStyles.bodySR20.copyWith(
              color: context.semanticColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
