import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's outlined icon action (`185:101`, `175:3899`): white, a 1px
/// secondary-outline border, radius 8, the glyph in the action colour.
///
/// Drawn at [size]; below 48 it needs a `HitTargetExtender` and a
/// `HitTargetScope` from its parent for a full touch target.
class AppOutlineIconButton extends StatelessWidget {
  const AppOutlineIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  /// Sized and coloured by the button through [IconTheme].
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final radius = BorderRadius.circular(AppSizes.r8);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        child: Material(
          color: s.containerBackground,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: s.secondaryButtonOutline),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: onPressed == null ? s.iconDisabled : s.actionIcon,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
