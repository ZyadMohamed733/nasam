import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_status_tones.dart';
import '../../core/theme/app_text_styles.dart';

/// A result count (`561:16911`): the value in Bold 14 in the tone's colour
/// over its label, centred on the tone's fill. 82 tall, radius 8; give it
/// its width from the parent (four share a row in the design).
class AppSummaryTile extends StatelessWidget {
  const AppSummaryTile({
    super.key,
    required this.tone,
    required this.value,
    required this.label,
  });

  final AppTone tone;
  final int value;
  final String label;

  static const double height = 82;
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const double gap = 8;

  @override
  Widget build(BuildContext context) {
    final colors = AppStatusTones.of(context)[tone];
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: height),
        padding: padding,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: AppTextStyles.bodyMB.copyWith(color: colors.foreground),
            ),
            const SizedBox(height: gap),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionS.copyWith(
                color: context.semanticColors.textPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
