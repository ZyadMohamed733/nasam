import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's Type axis. There is no "danger" button in the design: an
/// error-coloured action is a primary button on a screen that is already in an
/// error state, so it is not a variant here.
enum AppButtonVariant {
  /// Filled with the brand colour.
  primary,

  /// White (or a white tint in dark mode) with a 1px outline.
  secondary,

  /// Text only — no background, no border.
  tertiary,
}

/// The design's shared button.
///
/// Height is 44. The design's component set labels a 36pt "Medium" size, but
/// every real in-screen instance measures 44, so 44 is what ships.
///
/// Width is full-bleed by default. The screens that do not want that give an
/// explicit width and centre the button themselves — [AppSizes.formContentWidth]
/// on auth, [AppSizes.onboardingButtonWidth] on onboarding.
///
/// Every colour resolves from the theme's [AppSemanticColors], including the
/// disabled and hover states, which the design specifies as real colours. That
/// is why there is no `Opacity` wrapper here: it would force a `saveLayer` on
/// every button and produce a washed-out approximation of a colour the design
/// already names.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.width,
  });

  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final bool isLoading;

  /// Drawn at 16 before the label, per the design's inline icon size.
  final IconData? icon;

  /// Drawn at 16 after the label — which under RTL puts it on the left, the
  /// way the onboarding and auth buttons carry their onward arrow.
  final IconData? trailingIcon;

  /// Defaults to full width.
  final double? width;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: _primaryStyle(context, semantic),
          child: _content(context, semantic),
        ),
        AppButtonVariant.secondary => OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: _secondaryStyle(context, semantic),
          child: _content(context, semantic),
        ),
        AppButtonVariant.tertiary => TextButton(
          onPressed: _enabled ? onPressed : null,
          style: _tertiaryStyle(context, semantic),
          child: _content(context, semantic),
        ),
      },
    );
  }

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.r8)),
  );

  static const _padding = EdgeInsets.symmetric(horizontal: AppSizes.p8);

  ButtonStyle _primaryStyle(BuildContext context, AppSemanticColors s) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(context.textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return s.primaryButtonDisabled;
        }
        if (_isHighlighted(states)) return s.primaryButtonHover;
        return s.primaryButtonBackground;
      }),
      foregroundColor: WidgetStatePropertyAll(s.primaryButtonText),
      // The background already changes on hover; an ink overlay on top of it
      // would double the effect.
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  ButtonStyle _secondaryStyle(BuildContext context, AppSemanticColors s) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      textStyle: WidgetStatePropertyAll(context.textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (_isHighlighted(states)) return s.secondaryButtonHover;
        return s.secondaryButtonBackground;
      }),
      // The design specifies a disabled colour for the primary button only.
      // Secondary and tertiary fall back to the placeholder text colour, which
      // is the palette's "de-emphasised text" token.
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? s.textPlaceholder
            : s.secondaryButtonText,
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? s.iconDisabled
              : s.secondaryButtonOutline,
        ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  ButtonStyle _tertiaryStyle(BuildContext context, AppSemanticColors s) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      textStyle: WidgetStatePropertyAll(context.textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => _isHighlighted(states)
            ? s.secondaryButtonHover
            : Colors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? s.textPlaceholder
            : s.secondaryButtonText,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// Pointer hover and touch press share one visual state: a phone has no
  /// hover, so without this the design's hover colour would never be seen.
  static bool _isHighlighted(Set<WidgetState> states) =>
      states.contains(WidgetState.hovered) ||
      states.contains(WidgetState.pressed);

  Widget _content(BuildContext context, AppSemanticColors s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppIconSize.small.value,
            height: AppIconSize.small.value,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSizes.p4),
        ] else if (icon != null) ...[
          Icon(icon, size: AppIconSize.small.value),
          const SizedBox(width: AppSizes.p4),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSizes.p4),
          Icon(trailingIcon, size: AppIconSize.small.value),
        ],
      ],
    );
  }
}
