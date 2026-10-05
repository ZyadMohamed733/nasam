import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';

/// Displays a compact duration or status value for the segment.
class AssetStatusWidget extends StatelessWidget {
  const AssetStatusWidget({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    this.outlined = true,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final bool outlined;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$semanticsLabel $label',
      child: Container(
        padding: outlined
            ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h)
            : EdgeInsets.zero,
        decoration: outlined
            ? BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(7.r),
        )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.extraSmall.value.r,
              color: outlined ? scheme.primary : scheme.onSurfaceVariant,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: emphasize ? 10.sp : 9.sp,
                fontWeight: emphasize ? FontWeight.w700 : null,
                color: emphasize ? scheme.onSurface : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}