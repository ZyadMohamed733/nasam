import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../domain/tracking_vehicle.dart';

/// Tracking-specific semantic tokens transcribed from the map reference.
abstract final class TrackingStyle {
  static const drawer = Color(0xFF2E2166);
  static const drawerText = Color(0xFFDDD4F0);
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
