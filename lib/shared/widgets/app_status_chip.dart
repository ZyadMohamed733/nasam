import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_status_tones.dart';
import '../../core/theme/app_text_styles.dart';
import 'hit_target.dart';

/// A status chip (`561:13778`): the label in the tone's colour on its fill,
/// with an optional round count badge after it. Selected, it takes the
/// tone's border.
///
/// As a filter ([onTap] set) it draws 32 tall and at least [minWidth] wide,
/// and answers touches across 48 through a `HitTargetExtender` — so place
/// filter chips under a `HitTargetScope`. Without [onTap] it is a plain
/// status label, as in a table cell.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.tone,
    required this.label,
    this.count,
    this.selected = false,
    this.onTap,
  });

  final AppTone tone;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;

  static const double height = 32;
  static const double minWidth = 102;
  static const double padding = 8;
  static const double gap = 4;
  static const double badge = 16;

  @override
  Widget build(BuildContext context) {
    final colors = AppStatusTones.of(context)[tone];
    final radius = BorderRadius.circular(AppSizes.r8);
    final count = this.count;
    final chip = Material(
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected ? BorderSide(color: colors.border) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            minWidth: onTap == null ? 0 : minWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySR20.copyWith(
                    color: colors.foreground,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: gap),
                  _Badge(count: count, colors: colors),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return chip;
    return HitTargetExtender(
      child: Semantics(button: true, selected: selected, child: chip),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.colors});

  final int count;
  final AppStatusTone colors;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(
      minWidth: AppStatusChip.badge,
      minHeight: AppStatusChip.badge,
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppStatusChip.badge / 2),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p2),
        // Sized to the count, not to the space the row offers.
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            '$count',
            style: AppTextStyles.captionS.copyWith(color: colors.foreground),
          ),
        ),
      ),
    ),
  );
}
