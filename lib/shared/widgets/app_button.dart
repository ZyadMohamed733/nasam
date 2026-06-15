import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.prefixIcon,
    this.width,
    this.height,
  });

  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? prefixIcon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonHeight = height ?? AppSizes.buttonHeight.h;
    final isDisabled = onPressed == null || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: SizedBox(
        width: width ?? double.infinity,
        height: buttonHeight,
        child: _buildButtonType(context, isDark),
      ),
    );
  }

  Widget _buildButtonType(BuildContext context, bool isDark) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(isDark)),
            ),
          ),
          SizedBox(width: AppSizes.p12.w),
        ] else if (prefixIcon != null) ...[
          Icon(prefixIcon, size: AppSizes.iconSm.r, color: _getTextColor(isDark)),
          SizedBox(width: AppSizes.p8.w),
        ],
        Text(
          label,
          style: AppTextStyles.button.copyWith(color: _getTextColor(isDark)),
        ),
      ],
    );

    if (variant == AppButtonVariant.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12.r),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12.r),
        ),
      ),
      child: child,
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColors.primaryLight : AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.accent;
      case AppButtonVariant.danger:
        return AppColors.error;
      case AppButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDark) {
    if (variant == AppButtonVariant.outline) {
      return isDark ? AppColors.textPrimaryDark : AppColors.primary;
    }
    return Colors.white;
  }
}
