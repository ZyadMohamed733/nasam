import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_component_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_file_drop_zone.dart';
import '../../../../../shared/widgets/hit_target.dart';
import '../../../domain/entities/poi_limits.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_file_row.dart';
import 'poi_import_layout.dart';

/// Step 1, Upload (`561:12170`): the limits and template download on the
/// card's band, then the drop zone — and, once a file is chosen, its row.
class PoiImportUploadView extends StatelessWidget {
  const PoiImportUploadView({super.key, required this.state});

  final PoiImportState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final cubit = context.read<PoiImportCubit>();
    final file = state.file;
    final radius = BorderRadius.circular(AppSizes.r8);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: s.containerBorder),
      ),
      child: Padding(
        // Inside the card's 1px border, as the design's frame lays it out.
        padding: const EdgeInsets.all(PoiImportLayout.cardBorder),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppSizes.r8 - PoiImportLayout.cardBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Band(),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PoiImportLayout.dropAreaHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    PoiImportLayout.dropAreaPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFileDropZone(
                        title: l.poiDropTitle,
                        // The format reads left to right inside Arabic.
                        hint: l.poiDropHint(
                          '\u2066${PoiLimits.fileExtension}\u2069',
                          PoiLimits.maxFileMegabytes,
                        ),
                        browseLabel: l.poiBrowse,
                        loading: state.busy,
                        onBrowse: state.busy ? null : cubit.pick,
                      ),
                      if (file != null) ...[
                        const SizedBox(height: PoiImportLayout.fileRowGap),
                        HitTargetScope(
                          child: PoiImportFileRow(
                            file: file,
                            onRemove: state.busy ? null : cubit.clearFile,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card's top band: the three limits and the template download.
class _Band extends StatefulWidget {
  const _Band();

  @override
  State<_Band> createState() => _BandState();
}

class _BandState extends State<_Band> {
  bool _saving = false;

  Future<void> _template() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await context.read<PoiImportCubit>().saveTemplate();
      if (saved) {
        messenger.showSnackBar(SnackBar(content: Text(l.poiFileSaved)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.poiFileError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final colors = AppComponentColors.of(context);
    return Container(
      padding: const EdgeInsets.all(PoiImportLayout.bandPadding),
      decoration: BoxDecoration(
        color: colors.tableHeaderFill,
        border: Border.all(color: s.containerBorder),
      ),
      child: HitTargetScope(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: PoiImportLayout.bandPadding,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(l.poiFormatLabel, PoiLimits.fileExtension),
                _InfoRow(
                  l.poiMaxSizeLabel,
                  l.poiSizeMegabytes(PoiLimits.maxFileMegabytes),
                ),
                _InfoRow(l.poiMaxRecordsLabel, '${PoiLimits.maxRecords}'),
              ],
            ),
            HitTargetExtender(
              child: AppButton(
                label: l.poiTemplate,
                assetIcon: AppAssets.poiImport,
                iconColor: s.iconSecondary,
                iconSize: PoiImportLayout.templateIcon,
                variant: AppButtonVariant.secondary,
                width: PoiImportLayout.templateWidth,
                height: PoiImportLayout.templateHeight,
                labelStyle: AppTextStyles.bodySR20,
                isLoading: _saving,
                onPressed: _template,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label, value;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: PoiImportLayout.infoRowHeight,
      ),
      child: Wrap(
        spacing: PoiImportLayout.infoGap,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySR20.copyWith(color: s.textPlaceholder),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.bodySR20.copyWith(
              color: AppComponentColors.of(context).emphasisText,
            ),
          ),
        ],
      ),
    );
  }
}
