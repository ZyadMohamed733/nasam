import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/map_icon_button.dart';

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

/// Compatibility name for existing tracking call sites.
typedef TrackingIconButton = MapIconButton;

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
