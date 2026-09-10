import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

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

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      titlePadding: const EdgeInsets.only(
        top: AppSizes.p24,
        left: AppSizes.p24,
        right: AppSizes.p24,
      ),
      contentPadding: const EdgeInsets.all(AppSizes.p24),
      actionsPadding: const EdgeInsets.only(
        bottom: AppSizes.p16,
        left: AppSizes.p24,
        right: AppSizes.p24,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizes.iconXl,
              color: iconColor ?? AppColors.primary,
            ),
            const SizedBox(height: AppSizes.p16),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 40),
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
