import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_component_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'poi_import_layout.dart';

/// A step's title and description (`561:13774`, `561:15177`): Bold 18 in
/// the section title colour, then 8 below it the description in grey 14.
class PoiImportTitle extends StatelessWidget {
  const PoiImportTitle({
    super.key,
    required this.title,
    required this.description,
    this.centred = false,
  });

  final String title;
  final String description;

  /// Centred, as on Confirm's card.
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final align = centred ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centred
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: align,
            style: AppTextStyles.bodyXLB.copyWith(
              color: AppComponentColors.of(context).sectionTitle,
            ),
          ),
        ),
        const SizedBox(height: PoiImportLayout.titleGap),
        Text(
          description,
          textAlign: align,
          style: AppTextStyles.bodyMR.copyWith(
            color: context.semanticColors.textPlaceholder,
          ),
        ),
      ],
    );
  }
}
