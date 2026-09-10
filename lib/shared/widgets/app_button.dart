import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

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
    // The disabled look comes from the button themes' disabled colours rather
    // than an Opacity wrapper, which forced a saveLayer on every button.
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppSizes.buttonHeight,
      child: variant == AppButtonVariant.outline
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: _label(context),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: _elevatedOverride(context),
              child: _label(context),
            ),
    );
  }

  /// Only the variants that differ from the theme's default override it.
  ButtonStyle? _elevatedOverride(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.outline => null,
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
    };
  }

  Widget _label(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: AppSizes.iconSm,
            height: AppSizes.iconSm,
            // Inherits the button's foreground colour from the theme.
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: AppSizes.p12),
        ] else if (prefixIcon != null) ...[
          Icon(prefixIcon, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.p8),
        ],
        Text(label),
      ],
    );
  }
}
