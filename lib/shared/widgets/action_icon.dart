import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_icons.dart';

/// A compact icon action inside a padded touch target.
///
/// Pass [disabledHint] when a disabled action needs an explanation.
class ActionIcon extends StatelessWidget {
  const ActionIcon({
    super.key,
    this.icon,
    this.asset,
    required this.label,
    this.onPressed,
    this.disabledHint,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final String? asset;
  final String label;
  final VoidCallback? onPressed;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(4.r);
    final tooltip = !enabled && disabledHint != null
        ? '$label · $disabledHint'
        : label;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: enabled ? null : disabledHint,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: kMinInteractiveDimension.w,
              minHeight: kMinInteractiveDimension.h,
            ),
            child: Center(
              child: Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: asset != null
                    ? SvgPicture.asset(
                        asset!,
                        width: AppIconSize.small.value.r,
                        height: AppIconSize.small.value.r,
                        colorFilter: ColorFilter.mode(
                          enabled
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: .38),
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      )
                    : Icon(
                        icon,
                        size: AppIconSize.small.value.r,
                        color: enabled
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: .38),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
