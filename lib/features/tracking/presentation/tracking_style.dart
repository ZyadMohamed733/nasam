import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../domain/tracking_vehicle.dart';

/// Tracking-specific semantic tokens transcribed from the map reference.
abstract final class TrackingStyle {
  static const drawer = Color(0xFF2E2166);
  static const drawerText = Color(0xFFDDD4F0);

  /// Fill for the rounded accent shape at the bottom of [TrackingDrawer].
  ///
  /// Sampled from the light-lavender region of the now-retired
  /// `drawer_background.png`. That image (and its Figma sibling
  /// `drawer_bottom_background.svg`, whose fill is an unusable
  /// `<pattern>` -- flutter_svg doesn't support those, same issue as
  /// `Vector.svg`, see [AppLogo]) have both been replaced by a plain
  /// clipped shape so this single constant is the actual, code-level
  /// control over the drawer's background colour.
  static const drawerBottomAccent = Color(0xFFD3CFE0);

  static Color status(BuildContext context, VehicleStatus status) =>
      switch (status) {
        VehicleStatus.moving => const Color(0xFF17663A),
        VehicleStatus.idle => const Color(0xFFAC7600),
        VehicleStatus.stopped => const Color(0xFFE0004D),
        VehicleStatus.offline => Theme.of(
          context,
        ).extension<AppSemanticColors>()!.textPlaceholder,
      };
  static String label(AppLocalizations l, VehicleStatus status) =>
      switch (status) {
        VehicleStatus.moving => l.trackingMoving,
        VehicleStatus.idle => l.trackingIdle,
        VehicleStatus.stopped => l.trackingStopped,
        VehicleStatus.offline => l.trackingOffline,
      };
}
