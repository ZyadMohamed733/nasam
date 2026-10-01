import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_text_styles.dart';

/// A read-only section (`553:4391`): a white card, radius 8, with a soft
/// shadow; its title on a 12 row, then 10 below it the values.
class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key, required this.title, required this.child});

  final String title;

  /// One or more [AppInfoValue]s.
  final Widget child;

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 16,
  );
  static const double gap = 10;
  static const double titleSize = 11;
  static const double titleRow = 12;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: s.containerBackground,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        boxShadow: [
          BoxShadow(
            color: s.cardShadow,
            offset: const Offset(0, 1),
            blurRadius: 7,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                // Caption M, on the design's 12 title row.
                style: AppTextStyles.captionM.copyWith(
                  color: s.textColor,
                  height: titleRow / titleSize,
                ),
              ),
            ),
            const SizedBox(height: gap),
            child,
          ],
        ),
      ),
    );
  }
}

/// A value in an [AppInfoSection] (`553:4392`): a grey box, radius 8, at
/// least [minHeight] tall, with an optional 10pt label and 4 below it the
/// value in Bold 14 — or any [child] in its place — centred vertically.
class AppInfoValue extends StatelessWidget {
  const AppInfoValue({
    super.key,
    this.label,
    this.value,
    this.child,
    this.minHeight = defaultHeight,
    this.valueDirection,
  }) : assert((value == null) != (child == null));

  final String? label;
  final String? value;
  final Widget? child;
  final double minHeight;

  /// Pins [value] to a direction — coordinates read LTR in Arabic too.
  final TextDirection? valueDirection;

  /// The design fixes each box's height and centres its content, which
  /// overrides the frame's 16 vertical padding.
  static const double defaultHeight = 60;
  static const double notesHeight = 110;
  static const double paddingH = 8;
  static const double paddingV = 8;
  static const double gap = 4;
  static const double labelSize = 10;
  static const double labelRow = 11;

  static TextStyle valueStyle(BuildContext context) =>
      AppTextStyles.bodyMB.copyWith(color: context.semanticColors.textColor);

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final label = this.label;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: s.infoValueSurface,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label,
                  // Caption S, on the design's 11 label row.
                  style: AppTextStyles.captionS.copyWith(
                    height: labelRow / labelSize,
                    color: s.textPlaceholder,
                  ),
                ),
                const SizedBox(height: gap),
              ],
              child ??
                  Text(
                    value!,
                    textDirection: valueDirection,
                    // A pinned direction still lines up with the ambient
                    // start, as the design draws coordinates in Arabic.
                    textAlign: Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    style: valueStyle(context),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
