import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

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
            Icons.error_outline_rounded,
            size: AppSizes.iconXl.r,
            color: AppColors.error,
          ),
          SizedBox(height: AppSizes.p16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppSizes.p24.h),
            AppButton(
              width: 140.w,
              height: 40.h,
              onPressed: onRetry,
              label: retryLabel,
            ),
          ],
          ],
        ),
      ),
    );
  }
}
