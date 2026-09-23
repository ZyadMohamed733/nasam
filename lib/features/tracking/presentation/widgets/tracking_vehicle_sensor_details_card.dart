import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../dummy_data/tracking_all_dummy_data.dart';

class TrackingVehicleSensorDetailsCard extends StatelessWidget {
  const TrackingVehicleSensorDetailsCard({super.key, required this.details});

  final TrackingVehicleDetailsSample details;

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
              Text(details.sensorCode, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.primary)),
              SizedBox(width: 6.w),
              Icon(Icons.info_outline, size: 16.r, color: scheme.primary),
            ],
          ),
          SizedBox(height: 8.h),
          _SensorReading(icon: Icons.bolt_outlined, value: '${details.sensorBatteryMillivolts} mV'),
          SizedBox(height: 6.h),
          _SensorReading(icon: Icons.speed_outlined, value: '${details.sensorDistanceKm} km'),
          SizedBox(height: 10.h),
          Row(
            children: [
              IconButton(
                tooltip: l.vehicleDetailsSensorHistory,
                visualDensity: VisualDensity.compact,
                onPressed: () {},
                icon: Icon(Icons.history, size: 20.r),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.surface,
                  foregroundColor: scheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide(color: scheme.outlineVariant)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: FilledButton(onPressed: () {}, child: Text(l.vehicleDetailsDownload)),
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
        Icon(icon, size: 16.r, color: scheme.primary),
        SizedBox(width: 8.w),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.primary)),
      ],
    );
  }
}
