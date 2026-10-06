import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nasam/features/play_back/presentation/widgets/playback_item_card/time_label.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/tracking_colors.dart';
import '../../../../../shared/widgets/action_icon.dart';
import '../../../../../shared/widgets/route_progress.dart';
import '../../../domain/entities/playback_segment.dart';
import 'asset_status_widget.dart';
import 'location_label.dart';

class PlaybackItemCard extends StatefulWidget {
  const PlaybackItemCard({
    super.key,
    required this.segment,
    required this.locale,
    required this.playing,
    required this.onPlayPressed,
  });

  final PlaybackSegment segment;
  final String locale;
  final bool playing;
  final VoidCallback onPlayPressed;

  @override
  State<PlaybackItemCard> createState() => _PlaybackItemCardState();
}

class _PlaybackItemCardState extends State<PlaybackItemCard> {
  double _progress = .98;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat.jm(widget.locale);
    final dateFormat = DateFormat.yMMMd(widget.locale);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: .08),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Segment start and end timestamps.
          Row(
            textDirection: ui.TextDirection.ltr,
            children: [
              Expanded(
                child: TimeLabel(
                  time: timeFormat.format(widget.segment.startedAt),
                  date: dateFormat.format(widget.segment.startedAt),
                  leading: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TimeLabel(
                  time: timeFormat.format(widget.segment.endedAt),
                  date: dateFormat.format(widget.segment.endedAt),
                  leading: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          /// Playback timeline with its leading direction icon.
          RouteProgress(
            progress: _progress,
            onProgressChanged: (value) => setState(() => _progress = value),
          ),
          /// Start and end location labels below the timeline.
          Padding(
            padding: EdgeInsetsDirectional.only(start: 3.w, top: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 130.w),
                  child: LocationLabel(
                    place: widget.segment.startPlace,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10.sp),
                    iconColor: scheme.onSurfaceVariant,
                    iconSize: AppIconSize.extraSmall.value.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: LocationLabel(
                    place: widget.segment.endPlace,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10.sp),
                    iconColor: scheme.onSurfaceVariant,
                    iconSize: AppIconSize.extraSmall.value.r,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          /// Play or pause action alongside segment duration and status.
          Row(
            textDirection: ui.TextDirection.ltr,
            children: [
              AppAssetsIconWidget(
                label: widget.playing
                    ? l.assetPlaybackPause
                    : l.assetPlaybackPlay,
                onPressed: widget.onPlayPressed,
                asset: widget.playing
                    ? AppAssets.pauseIcon
                    : AppAssets.playIcon,
                size: AppIconSize.small.value.r,
                boxDecoration: BoxDecoration(
                  color: TrackingColors.of(context).playbackPrimary,
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  AssetStatusWidget(
                    icon: Icons.access_time,
                    label:
                        '${widget.segment.durationMinutes} ${l.assetPlaybackMinutes}',
                    semanticsLabel: l.assetPlaybackDuration,
                    outlined: false,
                    emphasize: true,
                  ),
                  SizedBox(width: 8.w),
                  AssetStatusWidget(
                    icon: Icons.local_parking_outlined,
                    label: widget.segment.status,
                    semanticsLabel: widget.segment.endPlace,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
