import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/tracking_vehicle.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import '../tracking_style.dart';
import '../utils/tracking_driver_initials.dart';
import '../../../../shared/widgets/app_card.dart';

class TrackingVehicleCard extends StatelessWidget {
  const TrackingVehicleCard({super.key, required this.vehicle});
  final TrackingAllDummyVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = TrackingStyle.status(context, vehicle.status);
    final label = TrackingStyle.label(l, vehicle.status);
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      borderRadius: 10.r,
      elevation: 0,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15.r,
                child: Icon(Icons.navigation, size: 16.r),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${vehicle.code} • ٠٧ م ٠٩ ث',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(label: label, color: color, status: vehicle.status),
            ],
          ),
          SizedBox(height: 14.h),
          _RouteProgress(progress: vehicle.routeProgress, color: color),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _ActionIcon(icon: Icons.videocam_outlined),
              _ActionIcon(icon: Icons.chat_bubble_outline),
              _ActionIcon(icon: Icons.my_location_outlined),
              _ActionIcon(icon: Icons.play_arrow_outlined),
            ],
          ),
          Divider(height: 12.h, color: scheme.outlineVariant),
          Row(
            children: [
              CircleAvatar(
                radius: 15.r,
                backgroundColor: scheme.primary,
                child: Text(
                  TrackingDriverInitials.fromName(vehicle.driver),
                  style: TextStyle(color: scheme.onPrimary, fontSize: 10.sp),
                ),
              ),

              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.driver,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      l.trackingVehicle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _ActionIcon(icon: Icons.call_outlined),
              SizedBox(width: 6.w),
              _ActionIcon(icon: Icons.mail_outline),
            ],
          ),
        ],
      ),
    );
  }
}
//ss
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color, required this.status});
  final String label;
  final Color color;
  final VehicleStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      border: Border.all(color: color.withValues(alpha: .25)),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_statusIcon(status), color: color, size: 12.r),
        SizedBox(width: 5.w),
        Text(label, style: TextStyle(color: color, fontSize: 10.sp)),
      ],
    ),
  );
}

class _RouteProgress extends StatelessWidget {
  const _RouteProgress({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 8.r, color: Theme.of(context).colorScheme.outline),
      SizedBox(width: 6.w),
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 2.h,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              color: color,
            ),
            Align(
              alignment: AlignmentDirectional(-1 + progress * 2, 0),
              child: CircleAvatar(
              radius: 11.r,
                backgroundColor: color.withValues(alpha: .12),
                child: Icon(Icons.navigation, size: 13.r, color: color),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 6.w),
      Icon(Icons.circle, size: 8.r, color: color),
    ],
  );
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(start: 5.w),
    child: SizedBox(
      width: 28.w,
      height: 28.h,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
        ),
        child: Icon(icon, size: 15.r),
      ),
    ),
  );
}

IconData _statusIcon(VehicleStatus status) => switch (status) {
  VehicleStatus.moving => Icons.check,
  VehicleStatus.idle => Icons.schedule,
  VehicleStatus.stopped => Icons.pause_circle_outline,
  VehicleStatus.offline => Icons.power_off_outlined,
};
