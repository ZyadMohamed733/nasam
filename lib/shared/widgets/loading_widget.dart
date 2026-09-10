import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.isFullScreen = false,
    this.size,
  });

  final bool isFullScreen;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final loader = Center(
      child: SizedBox(
        width: size ?? AppSizes.iconLg,
        height: size ?? AppSizes.iconLg,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.8)
            : AppColors.backgroundLight.withValues(alpha: 0.8),
        body: loader,
      );
    }

    return loader;
  }
}
