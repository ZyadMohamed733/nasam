import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = 1.0,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackRadius = borderRadius ?? AppSizes.r12;

    final container = Container(
      padding: padding ?? EdgeInsets.all(AppSizes.p16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(fallbackRadius.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow.withValues(
                    alpha: isDark ? 0.2 : 0.05,
                  ),
                  blurRadius: (elevation * 4).r,
                  offset: Offset(0, (elevation * 2).h),
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Card(
        elevation: 0,
        margin: margin ?? EdgeInsets.zero,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(fallbackRadius.r),
          child: container,
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: container,
    );
  }
}
