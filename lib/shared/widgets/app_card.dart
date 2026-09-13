import 'package:flutter/material.dart';
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
    final fallbackRadius = borderRadius ?? AppSizes.r12;

    final container = Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(fallbackRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.8,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.05,
                  ),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation * 2),
                ),
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
          borderRadius: BorderRadius.circular(fallbackRadius),
          child: container,
        ),
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: container);
  }
}
