import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/hit_target.dart';
import '../../domain/entities/alert_history_filter.dart';
import '../utils/alert_history_format.dart';

/// One chip per applied filter under the search field, each with a × that
/// drops just that filter ("Alert — Filter Applied", `988-17176`). Draws
/// nothing when no filter is applied.
class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final AlertHistoryFilter filter;

  /// The filter with the removed chip's part taken out.
  final ValueChanged<AlertHistoryFilter> onChanged;

  static const typeKey = ValueKey('applied-filter-type');
  static const dateKey = ValueKey('applied-filter-date');

  @override
  Widget build(BuildContext context) {
    if (!filter.isActive) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final type = filter.type;
    return HitTargetScope(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: AppSizes.p8,
          runSpacing: AppSizes.p8,
          children: [
            if (type != null)
              _AppliedChip(
                key: typeKey,
                label: AlertHistoryFormat.typeLabel(l, type),
                onRemove: () => onChanged(filter.withType(null)),
              ),
            if (filter.datePreset != null)
              _AppliedChip(
                key: dateKey,
                label: AlertHistoryFormat.dateChip(context, filter),
                onRemove: () => onChanged(filter.withDates(null)),
              ),
          ],
        ),
      ),
    );
  }
}

/// The filter's name, then a ×; the whole chip removes it.
class _AppliedChip extends StatelessWidget {
  const _AppliedChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  static const double height = 28;
  static const double icon = 14;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final radius = BorderRadius.circular(AppSizes.r8);
    return HitTargetExtender(
      child: Semantics(
        button: true,
        label: l.alertFilterRemove(label),
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: s.containerBorder),
          ),
          child: InkWell(
            onTap: onRemove,
            borderRadius: radius,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMR.copyWith(color: s.textColor),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Icon(Icons.close, size: icon, color: s.iconSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
