import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_sizes.dart';

/// A compact icon action inside a padded touch target.
////
/// Pass [disabledHint] when a disabled action needs an explanation.
class AppAssetsIconWidget extends StatelessWidget {
  const AppAssetsIconWidget({
    super.key,
    this.icon,
    this.asset,
    required this.label,
    this.onPressed,
    this.disabledHint,
    this.boxDecoration,
    this.size,
    this.containerSize,
    this.borderRadius,
    this.iconColor,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final String? asset;
  final double? size;
  final double? containerSize;
  final String label;
  final VoidCallback? onPressed;
  final String? disabledHint;
  final BoxDecoration? boxDecoration;
  final BorderRadius? borderRadius;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.r4);
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
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Center(
              child: Container(
                width: containerSize ?? AppSizes.iconButtonSmall,
                height: containerSize ?? AppSizes.iconButtonSmall,
                alignment: Alignment.center,
                decoration: boxDecoration,
                child: asset != null
                    ? SvgPicture.asset(
                        asset!,
                        width: size ?? AppSizes.iconSm,
                        height: size ?? AppSizes.iconSm,

                        excludeFromSemantics: true,
                      )
                    : Icon(
                        icon,
                        size: size ?? AppSizes.iconSm,
                        color:
                            iconColor ??
                            (enabled
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: .38)),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
