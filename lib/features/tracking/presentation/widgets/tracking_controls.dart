import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

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
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Material(
            color: menu
                ? scheme.surface
                : scheme.outline.withValues(alpha: .82),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: menu ? BorderSide(color: scheme.outline) : BorderSide.none,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SvgPicture.asset(
                    asset,
                    width: AppIconSize.medium.value.r,
                    height: AppIconSize.medium.value.r,
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
              top: 8,
              start: 12,
              child: TrackingIconButton(
                asset: AppAssets.trackingMenu,
                label: l.trackingMenu,
                onTap: openDrawer,
                menu: true,
              ),
            ),
            PositionedDirectional(
              top: 8,
              end: 12,
              child: TrackingIconButton(
                asset: AppAssets.mapNotification,
                label: l.trackingNotifications,
              ),
            ),
            Positioned(
              left: 8,
              top: constraints.maxHeight > 430 ? 156 : 64,
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
