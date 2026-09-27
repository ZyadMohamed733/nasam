import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/playback_segment.dart';

const _playbackTimelineColor = Color(0xFF8A8AA3);

class PlaybackSegmentCard extends StatefulWidget {
  const PlaybackSegmentCard({
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
  State<PlaybackSegmentCard> createState() => _PlaybackSegmentCardState();
}

class _PlaybackSegmentCardState extends State<PlaybackSegmentCard> {
  double _progress = .98;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat.jm(widget.locale);
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
          Row(
            textDirection: ui.TextDirection.ltr,
            children: [
              Expanded(
                child: _TimeLabel(
                  time: timeFormat.format(widget.segment.startedAt),
                  date: DateFormat.yMd(
                    widget.locale,
                  ).format(widget.segment.startedAt),
                  leading: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TimeLabel(
                  time: timeFormat.format(widget.segment.endedAt),
                  date: DateFormat.yMd(
                    widget.locale,
                  ).format(widget.segment.endedAt),
                  leading: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            textDirection: ui.TextDirection.ltr,
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 1.2.w,
                  ),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.mapArrowLeft,
                  width: AppIconSize.medium.value.r,
                  height: AppIconSize.medium.value.r,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _playbackTimelineColor,
                    inactiveTrackColor: _playbackTimelineColor,
                    thumbColor: _playbackTimelineColor,
                    trackHeight: 2.5.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 10.r),
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (value) => setState(() => _progress = value),
                  ),
                ),
              ),
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: _playbackTimelineColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 3.w, top: 2.h),
            child: Row(
              textDirection: ui.TextDirection.ltr,
              children: [
                Expanded(
                  child: Row(
                    textDirection: ui.TextDirection.ltr,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: AppIconSize.extraSmall.value.r,
                        color: scheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          widget.segment.startPlace,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(fontSize: 9.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Row(
                    textDirection: ui.TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: AppIconSize.extraSmall.value.r,
                        color: scheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          widget.segment.endPlace,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(fontSize: 9.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            textDirection: ui.TextDirection.ltr,
            children: [
              // The design's 34x32 button, inside a padded 48dp target.
              IconButton.filled(
                tooltip: widget.playing
                    ? l.assetPlaybackPause
                    : l.assetPlaybackPlay,
                padding: EdgeInsets.zero,
                onPressed: widget.onPlayPressed,
                icon: SvgPicture.asset(
                  widget.playing ? AppAssets.pauseIcon : AppAssets.playIcon,
                  width: AppIconSize.small.value.r,
                  height: AppIconSize.small.value.r,
                  excludeFromSemantics: true,
                ),
                style: IconButton.styleFrom(
                  fixedSize: Size(AppIconSize.medium.value, AppIconSize.medium.value),
                  minimumSize:  Size(AppIconSize.medium.value, AppIconSize.medium.value),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  _SegmentMetric(
                    icon: Icons.access_time,
                    label:
                    '${widget.segment.durationMinutes} ${l.assetPlaybackMinutes}',
                    semanticsLabel: l.assetPlaybackDuration,
                    outlined: false,
                    emphasize: true,
                  ),
                  SizedBox(width: 8.w),
                  _SegmentMetric(
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

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
    required this.time,
    required this.date,
    required this.leading,
  });

  final String time;
  final String date;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      textDirection: leading ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!leading)
          Icon(
            Icons.access_time,
            size: AppIconSize.extraSmall.value.r,
            color: scheme.onSurfaceVariant,
          ),
        if (!leading) SizedBox(width: 3.w),
        Flexible(
          child: Text(
            '$time · $date',
            textAlign: leading ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 9.sp),
          ),
        ),
        if (leading) SizedBox(width: 3.w),
        if (leading)
          Icon(
            Icons.access_time,
            size: AppIconSize.extraSmall.value.r,
            color: scheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _SegmentMetric extends StatelessWidget {
  const _SegmentMetric({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    this.outlined = true,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final bool outlined;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$semanticsLabel $label',
      child: Container(
        padding: outlined
            ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h)
            : EdgeInsets.zero,
        decoration: outlined
            ? BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(7.r),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.extraSmall.value.r,
              color: outlined ? scheme.primary : scheme.onSurfaceVariant,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: emphasize ? 10.sp : 9.sp,
                fontWeight: emphasize ? FontWeight.w700 : null,
                color: emphasize ? scheme.onSurface : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//test
