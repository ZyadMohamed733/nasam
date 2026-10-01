import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_component_colors.dart';
import '../../../../../core/theme/app_status_tones.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_summary_tile.dart';
import '../../../../../shared/widgets/hit_target.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_layout.dart';
import 'poi_import_title.dart';

/// Step 4, Confirm (`561:16904`): the result card — a check tile, the
/// title, and the import's real counts — then the way back to the map.
class PoiImportConfirmView extends StatelessWidget {
  const PoiImportConfirmView({super.key, required this.summary});

  final PoiImportSummary summary;

  static const showOnMapKey = ValueKey('poi-import-show-on-map');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = AppComponentColors.of(context);
    return HitTargetScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PoiImportLayout.cardPaddingH,
              vertical: PoiImportLayout.cardPaddingV,
            ),
            decoration: BoxDecoration(
              color: colors.infoCardFill,
              borderRadius: BorderRadius.circular(AppSizes.r8),
              boxShadow: [
                BoxShadow(
                  color: colors.elevationShadow,
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                _CheckTile(colors: colors),
                const SizedBox(height: PoiImportLayout.cardTextGap),
                PoiImportTitle(
                  title: l.poiImportTitle,
                  description: l.poiImportDoneDescription,
                  centred: true,
                ),
                const SizedBox(height: PoiImportLayout.cardGap),
                _Tiles(summary: summary),
              ],
            ),
          ),
          const SizedBox(height: PoiImportLayout.linkGap),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PoiImportLayout.linkInset,
              ),
              child: IntrinsicWidth(
                child: HitTargetExtender(
                  child: AppButton(
                    key: showOnMapKey,
                    label: l.poiShowPoints,
                    variant: AppButtonVariant.tertiary,
                    labelColor: context.semanticColors.actionIcon,
                    labelStyle: AppTextStyles.bodyMR,
                    // Back to the map, which reloads its list.
                    onPressed: () => context.pop(true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 64 tile with the filled check (`561:16906`).
class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.colors});

  final AppComponentColors colors;

  @override
  Widget build(BuildContext context) => Container(
    width: PoiImportLayout.iconTile,
    height: PoiImportLayout.iconTile,
    decoration: BoxDecoration(
      color: colors.iconTileFill,
      borderRadius: BorderRadius.circular(AppSizes.r8),
    ),
    child: Icon(
      Icons.check_circle,
      size: PoiImportLayout.iconTileGlyph,
      color: colors.infoCardFill,
    ),
  );
}

/// Total, imported, failed and duplicates, from the start.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.summary});

  final PoiImportSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tiles = [
      (AppTone.info, summary.total, l.poiTotal),
      (AppTone.success, summary.imported, l.poiImportSucceeded),
      (AppTone.danger, summary.failed, l.poiImportFailed),
      (AppTone.warning, summary.duplicates, l.poiImportDuplicates),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: PoiImportLayout.tileGap),
          Expanded(
            child: AppSummaryTile(
              tone: tiles[i].$1,
              value: tiles[i].$2,
              label: tiles[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}
