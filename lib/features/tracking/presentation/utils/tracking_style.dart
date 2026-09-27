import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../domain/entities/tracking_vehicle.dart';

/// How a vehicle status is shown: its colour from [TrackingColors], and the
/// icon and label that always go with it, so no status is told by colour
/// alone.
abstract final class TrackingStyle {
  static Color status(BuildContext context, VehicleStatus status) {
    final colors = TrackingColors.of(context);
    return switch (status) {
      VehicleStatus.moving => colors.moving,
      VehicleStatus.idle => colors.idle,
      VehicleStatus.stopped => colors.stopped,
      VehicleStatus.offline => colors.offline,
    };
  }

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
