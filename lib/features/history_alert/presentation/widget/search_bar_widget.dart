import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.isFilterActive = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final bool isFilterActive;

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
        SizedBox(
          width: 44.w,
          height: 44.h,
          child: IconButton(
            tooltip: l.alertFilter,
            onPressed: onFilterPressed,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: isFilterActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
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
      ],
    );
  }
}
