import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../utils/tracking_units.dart';

class TrackingAssetSensorDetailsCard extends StatelessWidget {
  const TrackingAssetSensorDetailsCard({super.key, required this.details});

  final TrackedAssetDetails details;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: .10),
            blurRadius: 5.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                details.sensorCode,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: scheme.primary),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.info_outline,
                size: AppIconSize.small.value.r,
                color: scheme.primary,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _SensorReading(
            icon: Icons.bolt_outlined,
            value: TrackingUnits.of(
              context,
            ).millivolts(details.sensorBatteryMillivolts),
          ),
          SizedBox(height: 6.h),
          _SensorReading(
            icon: Icons.speed_outlined,
            value: TrackingUnits.of(
              context,
            ).distanceKm(details.sensorDistanceKm),
          ),
          SizedBox(height: 10.h),
          // Neither action exists yet: shown, disabled, and announced as
          // coming soon rather than enabled and doing nothing.
          Row(
            children: [
              Semantics(
                hint: l.comingSoon,
                child: IconButton(
                  tooltip: '${l.assetDetailsSensorHistory} · ${l.comingSoon}',
                  onPressed: null,
                  icon: Icon(Icons.history, size: AppIconSize.medium.value.r),
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.surface,
                    foregroundColor: scheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Semantics(
                  hint: l.comingSoon,
                  child: FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        kMinInteractiveDimension,
                      ),
                    ),
                    child: Text(l.assetDetailsDownload),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorReading extends StatelessWidget {
  const _SensorReading({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.small.value.r, color: scheme.primary),
        SizedBox(width: 8.w),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }
}
