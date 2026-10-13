import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.filterCount = 0,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  /// How many filters are applied, shown as a badge on the filter button
  /// when there are any ("Alert — Filter Applied", `988-17176`).
  final int filterCount;

  static const filterButtonKey = ValueKey('alert-search-filter-button');
  static const badgeKey = ValueKey('alert-search-filter-badge');
  static const double badgeSize = 18;

  /// How far the badge's centre sits in from the button's top-end corner —
  /// the left in Arabic, as the design draws it.
  static const double badgeInset = 4;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: AppColors.neutral200),
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 12.sp),
              decoration: InputDecoration(
                hintText: l.trackingSearch,
                hintStyle: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18.r,
                  color: AppColors.neutral500,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: const BorderSide(color: AppColors.neutral400),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 44.w,
              height: 44.h,
              child: Semantics(
                value: filterCount > 0 ? '$filterCount' : null,
                child: IconButton(
                  key: filterButtonKey,
                  tooltip: l.alertFilter,
                  onPressed: onFilterPressed,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: AppColors.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    AppAssets.filter,
                    width: 18.r,
                    height: 18.r,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            if (filterCount > 0)
              PositionedDirectional(
                end: badgeInset - badgeSize / 2,
                top: badgeInset - badgeSize / 2,
                child: ExcludeSemantics(
                  child: _CountBadge(key: badgeKey, count: filterCount),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The applied-filter count: white on the brand colour, in a circle.
class _CountBadge extends StatelessWidget {
  const _CountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    return Container(
      width: SearchBarWidget.badgeSize,
      height: SearchBarWidget.badgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: s.primaryButtonBackground,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: AppTextStyles.captionSB.copyWith(color: s.primaryButtonText),
      ),
    );
  }
}
