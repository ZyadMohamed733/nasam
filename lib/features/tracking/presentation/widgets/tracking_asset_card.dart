import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/bidi.dart';
import '../../../../shared/widgets/action_icon.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/route_progress.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../utils/tracking_person_initials.dart';
import '../utils/tracking_style.dart';
import '../utils/tracking_units.dart';

class TrackingAssetCard extends StatelessWidget {
  const TrackingAssetCard({super.key, required this.asset});
  final TrackedAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isStopped = asset.status == VehicleStatus.stopped;
    final color = TrackingStyle.status(context, asset.status);
    final label = TrackingStyle.label(l, asset.status);
    final scheme = Theme.of(context).colorScheme;
    final actionIconDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(color: scheme.outlineVariant),
    );
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
                    color: Colors.white.withValues(alpha: .15),
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
                      joinIsolated([
                        asset.code,
                        if (asset.statusDuration case final d?)
                          TrackingUnits.of(context).duration(d),
                      ], ' • '),
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
              // Keep the badge flush to the card's trailing edge. The title
              // takes the remaining row width, while long labels stay bounded.
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _StatusBadge(
                    label: label,
                    color: color,
                    status: asset.status,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          RouteProgress(
            progress: asset.routeProgress,
            markerAtEnd: asset.status == VehicleStatus.stopped,
            color: color,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              AppAssetsIconWidget(
                asset: AppAssets.playOutlineIcon,
                label: l.assetPlaybackTitle,
                onPressed: () =>
                    context.push(AppRoutes.assetPlayback(asset.id)),
                boxDecoration: actionIconDecoration,
              ),
              AppAssetsIconWidget(
                asset: AppAssets.gps,
                label: l.trackingActionLocate,
                disabledHint: l.comingSoon,
                boxDecoration: actionIconDecoration,
              ),
              AppAssetsIconWidget(
                asset: AppAssets.message,
                label: l.trackingActionChat,
                disabledHint: l.comingSoon,
                boxDecoration: actionIconDecoration,
              ),
              AppAssetsIconWidget(
                asset: AppAssets.videoCameraRecord,
                label: l.trackingActionCamera,
                disabledHint: l.comingSoon,
                boxDecoration: actionIconDecoration,
              ),
            ],
          ),
          Divider(height: 12.h, color: scheme.outlineVariant),
          Row(
            children: [
              CircleAvatar(
                radius: 15.r,
                backgroundColor: isStopped
                    ? AppColors.neutral200
                    : scheme.primary,
                child: isStopped
                    ? Icon(
                        Icons.person,
                        color: AppColors.neutral600,
                        size: 18.r,
                      )
                    : Text(
                        TrackingPersonInitials.fromName(asset.assignedPerson),
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 10.sp,
                        ),
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
                      l.trackingLastUpdated,
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
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAssetsIconWidget(
                      asset: AppAssets.phoneCalling,
                      label: l.trackingActionCall,
                      disabledHint: l.comingSoon,
                      boxDecoration: actionIconDecoration,
                    ),
                    AppAssetsIconWidget(
                      asset: AppAssets.email,
                      label: l.trackingActionEmail,
                      disabledHint: l.comingSoon,
                      boxDecoration: actionIconDecoration,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          TrackingStyle.icon(status),
          color: color,
          size: AppIconSize.extraSmall.value.r,
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11.sp),
          ),
        ),
      ],
    ),
  );
}
