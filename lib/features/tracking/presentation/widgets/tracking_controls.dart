import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

/// Where the map's controls sit. Raw dp, like the buttons themselves: they
/// are touch targets, and 48dp is a floor that must not scale down.
abstract final class TrackingControlsLayout {
  /// The menu and notifications row's distance from the top and sides.
  static const double topRowInset = 8;
  static const double topRowSideInset = 12;

  /// The tool column's distance from the start edge.
  static const double toolColumnInset = 8;

  /// Where the tool column starts on a screen tall enough to leave the
  /// design's gap under the top row.
  static const double toolColumnTop = 156;

  /// Where it starts when the screen is shorter than
  /// [compactHeightBreakpoint]: right under the top row (8 + 48 + 8).
  static const double compactToolColumnTop = 64;

  /// Below this height, the tool column moves up to stay clear of the sheet.
  static const double compactHeightBreakpoint = 430;

  /// A control's touch target, and its visible square inside it.
  static const double hitTarget = 48;
  static const double visual = 40;
  static const double radius = 8;
}

class TrackingIconButton extends StatelessWidget {
  const TrackingIconButton({
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
      child: SizedBox.square(
        dimension: TrackingControlsLayout.hitTarget,
        child: Center(
          child: Material(
            color: menu
                ? scheme.surface
                : scheme.outline.withValues(alpha: .82),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                TrackingControlsLayout.radius,
              ),
              side: menu ? BorderSide(color: scheme.outline) : BorderSide.none,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(
                TrackingControlsLayout.radius,
              ),
              child: SizedBox.square(
                dimension: TrackingControlsLayout.visual,
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

class TrackingControls extends StatelessWidget {
  const TrackingControls({
    super.key,
    required this.openDrawer,
    required this.onLayersTap,
    required this.onZoomIn,
    required this.onZoomOut,
  });
  final VoidCallback openDrawer;
  final VoidCallback onLayersTap;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            PositionedDirectional(
              top: TrackingControlsLayout.topRowInset,
              start: TrackingControlsLayout.topRowSideInset,
              child: TrackingIconButton(
                asset: AppAssets.trackingMenu,
                label: l.trackingMenu,
                onTap: openDrawer,
                menu: true,
              ),
            ),
            PositionedDirectional(
              top: TrackingControlsLayout.topRowInset,
              end: TrackingControlsLayout.topRowSideInset,
              child: TrackingIconButton(
                asset: AppAssets.mapNotification,
                label: l.trackingNotifications,
              ),
            ),
            // On the start side, with the menu: the right in Arabic.
            PositionedDirectional(
              start: TrackingControlsLayout.toolColumnInset,
              top:
                  constraints.maxHeight >
                      TrackingControlsLayout.compactHeightBreakpoint
                  ? TrackingControlsLayout.toolColumnTop
                  : TrackingControlsLayout.compactToolColumnTop,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TrackingIconButton(
                      asset: AppAssets.mapLayers,
                      label: l.trackingLayers,
                      onTap: onLayersTap,
                    ),
                    TrackingIconButton(
                      asset: AppAssets.mapZoomIn,
                      label: l.trackingZoomIn,
                      onTap: onZoomIn,
                    ),
                    TrackingIconButton(
                      asset: AppAssets.mapZoomOut,
                      label: l.trackingZoomOut,
                      onTap: onZoomOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
