import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'OK',
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: Icons.help_outline_rounded,
        iconColor: AppColors.primaryLight,
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'OK',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.info,
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'Dismiss',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
      ),
      titlePadding: EdgeInsets.only(
        top: AppSizes.p24.h,
        left: AppSizes.p24.w,
        right: AppSizes.p24.w,
      ),
      contentPadding: EdgeInsets.all(AppSizes.p24.r),
      actionsPadding: EdgeInsets.only(
        bottom: AppSizes.p16.h,
        left: AppSizes.p24.w,
        right: AppSizes.p24.w,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizes.iconXl.r,
              color: iconColor ?? AppColors.primary,
            ),
            SizedBox(height: AppSizes.p16.h),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
            child: Text(
              cancelLabel!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.w, 40.h),
            backgroundColor: iconColor ?? AppColors.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
