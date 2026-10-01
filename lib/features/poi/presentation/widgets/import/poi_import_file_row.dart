import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_component_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../cubit/poi_import_cubit.dart';
import 'poi_import_layout.dart';

/// The chosen workbook under the drop zone: its name and size, and a way to
/// remove it.
///
/// NOT IN THE DESIGN: no frame shows a chosen file (the Attachment
/// component has only its empty variant). See docs/backlog.md.
class PoiImportFileRow extends StatelessWidget {
  const PoiImportFileRow({
    super.key,
    required this.file,
    required this.onRemove,
  });

  final PoiImportFile file;
  final VoidCallback? onRemove;

  static const removeKey = ValueKey('poi-import-remove-file');

  /// "12.4 KB" / "1.2 MB"; empty when the picker gave no size.
  static String size(int bytes) {
    if (bytes <= 0) return '';
    const kb = 1024;
    return bytes < kb * kb
        ? '${(bytes / kb).toStringAsFixed(1)} KB'
        : '${(bytes / (kb * kb)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final size = PoiImportFileRow.size(file.size);
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: PoiImportLayout.fileRowPadding,
      ),
      decoration: BoxDecoration(
        color: AppComponentColors.of(context).tableHeaderFill,
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: PoiImportLayout.fileIcon,
            color: s.iconSecondary,
          ),
          const SizedBox(width: PoiImportLayout.fileIconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMR.copyWith(color: s.textColor),
                ),
                if (size.isNotEmpty)
                  Text(
                    size,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.captionS.copyWith(
                      color: s.textPlaceholder,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            key: removeKey,
            tooltip: l.poiRemoveFile,
            onPressed: onRemove,
            icon: Icon(
              Icons.close,
              size: AppSizes.iconSm,
              color: s.iconSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
