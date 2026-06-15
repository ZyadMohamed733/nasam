import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
  });

  final Widget child;
  final bool showDragHandle;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showDragHandle = true,
    bool isDismissible = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.r24.r),
        ),
      ),
      builder: (context) => AppBottomSheet(
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            SizedBox(height: AppSizes.p12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSizes.r4.r),
              ),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.p24.r),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
