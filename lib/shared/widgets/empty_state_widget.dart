import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onActionPressed,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(AppSizes.p24.r),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
            icon,
            size: AppSizes.iconXl.r,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          SizedBox(height: AppSizes.p16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            SizedBox(height: AppSizes.p24.h),
            AppButton(
              width: 160.w,
              height: 40.h,
              onPressed: onActionPressed,
              label: actionLabel!,
            ),
          ],
          ],
        ),
      ),
    );
  }
}
