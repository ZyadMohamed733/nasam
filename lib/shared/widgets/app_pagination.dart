import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_component_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'hit_target.dart';

/// A data table's footer (`561:13933`): page buttons at the start and the
/// total at the end, on the table fill, bottom corners rounded 8. 40 tall.
///
/// Shows up to [window] page numbers around [page]. Each 32×32 button
/// answers touches across 48 through a `HitTargetExtender`, so place the
/// footer under a `HitTargetScope` with room above and below it.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.totalLabel,
    required this.onPage,
  });

  /// Zero-based.
  final int page;
  final int pageCount;

  /// "إجمالي N poi".
  final String totalLabel;
  final ValueChanged<int>? onPage;

  static const double height = 40;
  static const double paddingH = 16;
  static const double button = 32;
  static const double buttonRadius = 6;
  static const double gap = 4;
  static const int window = 3;

  static ValueKey<String> pageKey(int page) => ValueKey('app-pagination-$page');

  @override
  Widget build(BuildContext context) {
    final colors = AppComponentColors.of(context);
    final first = (page - window ~/ 2).clamp(
      0,
      (pageCount - window).clamp(0, pageCount),
    );
    final last = (first + window).clamp(0, pageCount);
    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: paddingH),
      decoration: BoxDecoration(
        color: colors.tableHeaderFill,
        border: Border.all(color: colors.tableFooterBorder),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.r8),
        ),
      ),
      child: Row(
        children: [
          for (var i = first; i < last; i++) ...[
            if (i > first) const SizedBox(width: gap),
            HitTargetExtender(
              child: _PageButton(
                key: pageKey(i),
                page: i,
                current: i == page,
                colors: colors,
                onTap: onPage == null || i == page ? null : () => onPage!(i),
              ),
            ),
          ],
          const Spacer(),
          Flexible(
            flex: 0,
            child: Text(
              totalLabel,
              style: AppTextStyles.footnote.copyWith(
                color: colors.pageButtonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    super.key,
    required this.page,
    required this.current,
    required this.colors,
    required this.onTap,
  });

  final int page;
  final bool current;
  final AppComponentColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppPagination.buttonRadius);
    final label = '${page + 1}';
    return Semantics(
      button: true,
      selected: current,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: current ? colors.pageButtonActive : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: current
              ? BorderSide.none
              : BorderSide(color: colors.pageButtonBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox.square(
            dimension: AppPagination.button,
            child: Center(
              child: Text(
                label,
                style: current
                    ? AppTextStyles.bodySR.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.pageButtonActiveText,
                      )
                    : AppTextStyles.bodySR.copyWith(
                        color: colors.pageButtonText,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
