import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../tracking_style.dart';
import '../utils/tracking_person_initials.dart';

class TrackingAssetCard extends StatelessWidget {
  const TrackingAssetCard({super.key, required this.asset});
  final TrackedAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = TrackingStyle.status(context, asset.status);
    final label = TrackingStyle.label(l, asset.status);
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: () => context.push(AppRoutes.assetDetails(asset.id)),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      borderRadius: 10.r,
      elevation: 0,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: scheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.navigation_outlined,
                  color: Colors.white,
                  size: AppIconSize.small.value.r,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${asset.code} • ٠٧ م ٠٩ ث',
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
              _StatusBadge(label: label, color: color, status: asset.status),
            ],
          ),
          SizedBox(height: 14.h),
          _RouteProgress(progress: asset.routeProgress, color: color),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _ActionIcon(icon: Icons.videocam_outlined),
              _ActionIcon(icon: Icons.chat_bubble_outline),
              _ActionIcon(icon: Icons.my_location_outlined),
              _ActionIcon(
                icon: Icons.play_arrow_outlined,
                onPressed: () =>
                    context.push(AppRoutes.assetPlayback(asset.id)),
              ),
            ],
          ),
          Divider(height: 12.h, color: scheme.outlineVariant),
          Row(
            children: [
              CircleAvatar(
                radius: 15.r,
                backgroundColor: scheme.primary,
                child: Text(
                  TrackingPersonInitials.fromName(asset.assignedPerson),
                  style: TextStyle(color: scheme.onPrimary, fontSize: 10.sp),
                ),
              ),

              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assignedPerson,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      l.trackingAsset,
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
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.status,
  });
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
        Icon(
          _statusIcon(status),
          color: color,
          size: AppIconSize.extraSmall.value.r,
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10.sp),
        ),
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
      Icon(Icons.circle, size: AppIconSize.tiny.value.r, color: color),
      SizedBox(width: 6.w),
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // dashed track (the "unfilled" remainder)
            SizedBox(
              height: 4.h,
              width: double.infinity,
              child: CustomPaint(
                painter: _DashedLinePainter(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  strokeWidth: 1.h,
                ),
              ),
            ),
            // solid filled progress, covers dashed part up to `progress`
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(-1 + progress * 2, 0),
              child: CircleAvatar(
                radius: 11.r,
                backgroundColor: color.withValues(alpha: .12),
                child: RotatedBox(
                  quarterTurns: Directionality.of(context) == TextDirection.rtl
                      ? 3
                      : 1,
                  child: Icon(
                    Icons.navigation,
                    size: AppIconSize.small.value.r,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 6.w),
      Icon(Icons.circle, size: AppIconSize.tiny.value.r, color: color),
    ],
  );
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(start: 5.w),
    child: SizedBox(
      width: 28.w,
      height: 28.h,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Icon(icon, size: AppIconSize.small.value.r),
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
