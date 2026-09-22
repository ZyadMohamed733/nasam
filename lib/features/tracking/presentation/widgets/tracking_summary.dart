import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/tracking_vehicle.dart';
import '../cubit/tracking_cubit.dart';
import '../tracking_style.dart';

class TrackingSummary extends StatelessWidget {
  const TrackingSummary({super.key, required this.state});
  final TrackingState state;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 3,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.trackingTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(l.trackingShow, style: TextStyle(color: scheme.primary)),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(
                      context,
                      l.trackingAll,
                      state.vehicles.length,
                      scheme.primary,
                      null,
                    ),
                    for (final status in VehicleStatus.values)
                      _chip(
                        context,
                        TrackingStyle.label(l, status),
                        state.count(status),
                        TrackingStyle.status(context, status),
                        status,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    int count,
    Color color,
    VehicleStatus? status,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == null)
              SvgPicture.asset(
                AppAssets.mapArrow,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else
              Icon(
                switch (status) {
                  VehicleStatus.moving => Icons.check,
                  VehicleStatus.idle => Icons.schedule,
                  VehicleStatus.stopped => Icons.local_parking,
                  VehicleStatus.offline => Icons.power_off_outlined,
                },
                size: 16,
                color: color,
              ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: .3)),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 9, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
