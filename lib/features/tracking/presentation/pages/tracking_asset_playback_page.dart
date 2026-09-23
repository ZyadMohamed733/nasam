import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import '../dummy_data/tracking_asset_playback_dummy_data.dart';
import '../widgets/playback/playback_date_range_selector.dart';
import '../widgets/playback/playback_start_button.dart';
import '../widgets/playback/tracking_asset_playback_segment_card.dart';

class TrackingAssetPlaybackPage extends StatefulWidget {
  const TrackingAssetPlaybackPage({super.key, required this.asset});

  final TrackingAllDummyAsset asset;

  @override
  State<TrackingAssetPlaybackPage> createState() =>
      _TrackingAssetPlaybackPageState();
}

class _TrackingAssetPlaybackPageState extends State<TrackingAssetPlaybackPage> {
  late DateTime _fromDate = DateUtils.dateOnly(DateTime.now());
  late DateTime _toDate = DateUtils.dateOnly(DateTime.now());
  bool _playingAll = false;
  int? _playingSegmentIndex;

  Future<void> _chooseDate({required bool isStart}) async {
    final current = isStart ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _fromDate = DateUtils.dateOnly(picked);
        if (_fromDate.isAfter(_toDate)) _toDate = _fromDate;
      } else {
        _toDate = DateUtils.dateOnly(picked);
        if (_toDate.isBefore(_fromDate)) _fromDate = _toDate;
      }
    });
  }

  void _togglePlayback() => setState(() {
    _playingAll = !_playingAll;
    if (_playingAll) _playingSegmentIndex = null;
  });

  void _toggleSegment(int index) => setState(() {
    _playingAll = false;
    _playingSegmentIndex = _playingSegmentIndex == index ? null : index;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final segments = TrackingAssetPlaybackDummyData.segments
        .where((segment) {
          final date = DateUtils.dateOnly(segment.startedAt);
          return !date.isBefore(_fromDate) && !date.isAfter(_toDate);
        })
        .toList(growable: false);

    final playbackTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.bluePurple700,
      ),
    );

    return Theme(
      data: playbackTheme,
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 64.h,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
          icon: IconTheme(
            data: IconThemeData(size: AppIconSize.medium.value.r),
            child: BackButtonIcon(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.assetPlaybackTitle, style: Theme.of(context).textTheme.titleSmall),
            Text(
              '${widget.asset.name} · ${widget.asset.code}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(14.w, 8.h, 14.w, 6.h),
              child: PlaybackDateRangeSelector(
                startDate: _fromDate,
                endDate: _toDate,
                onStartDateTap: () => _chooseDate(isStart: true),
                onEndDateTap: () => _chooseDate(isStart: false),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: PlaybackStartButton(
                playing: _playingAll,
                label: _playingAll ? l.assetPlaybackPause : l.assetPlaybackStart,
                onPressed: _togglePlayback,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: segments.isEmpty
                  ? Center(child: Text(l.assetPlaybackEmpty))
                  : ListView.separated(
                      padding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 14.w, 16.h),
                      itemCount: segments.length,
                      separatorBuilder: (context, index) => SizedBox(height: 7.h),
                      itemBuilder: (context, index) =>
                          TrackingAssetPlaybackSegmentCard(
                            segment: segments[index],
                            locale: locale,
                            playing: _playingAll || _playingSegmentIndex == index,
                            onPlayPressed: () => _toggleSegment(index),
                          ),
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
