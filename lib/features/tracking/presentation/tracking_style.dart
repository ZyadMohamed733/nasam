import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../domain/entities/tracking_vehicle.dart';

/// Tracking-specific semantic tokens transcribed from the map reference.
abstract final class TrackingStyle {
  static Color status(BuildContext context, VehicleStatus status) =>
      switch (status) {
        VehicleStatus.moving => const Color(0xFF17663A),
        VehicleStatus.idle => const Color(0xFFAC7600),
        VehicleStatus.stopped => const Color(0xFFE0004D),
        VehicleStatus.offline => Theme.of(
          context,
        ).extension<AppSemanticColors>()!.textPlaceholder,
      };

  /// Shown beside every status colour, so no status is told by colour alone.
  static IconData icon(VehicleStatus status) => switch (status) {
    VehicleStatus.moving => Icons.check,
    VehicleStatus.idle => Icons.schedule,
    VehicleStatus.stopped => Icons.local_parking,
    VehicleStatus.offline => Icons.power_off_outlined,
  };

  static String label(AppLocalizations l, VehicleStatus status) =>
      switch (status) {
        VehicleStatus.moving => l.trackingMoving,
        VehicleStatus.idle => l.trackingIdle,
        VehicleStatus.stopped => l.trackingStopped,
        VehicleStatus.offline => l.trackingOffline,
      };
}
