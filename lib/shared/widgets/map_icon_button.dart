import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/l10n/app_localizations.dart';

class MapIconButton extends StatelessWidget {
  const MapIconButton({
    super.key,
    required this.asset,
    required this.label,
    this.onTap,
    this.menu = false,
  });
  final String asset;
  final String label;
  final VoidCallback? onTap;
  final bool menu;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      // Not wired up yet: shown, but disabled and announced as such.
      hint: onTap == null ? AppLocalizations.of(context)!.comingSoon : null,
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Material(
            color: menu
                ? scheme.surface
                : scheme.outline.withValues(alpha: .82),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              side: menu ? BorderSide(color: scheme.outline) : BorderSide.none,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: SizedBox.square(
                dimension: 40,
                child: Center(
                  child: SvgPicture.asset(
                    asset,
                    width: AppIconSize.medium.value,
                    height: AppIconSize.medium.value,
                    excludeFromSemantics: true,
                    colorFilter: ColorFilter.mode(
                      menu ? scheme.onSurface : scheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
