import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_bar_widget.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../../../core/utils/bidi.dart';
import '../../../tracking/domain/entities/tracked_asset.dart';
import '../cubit/playback_cubit.dart';
import '../utils/playback_range.dart';
import '../widgets/playback_date_range_selector.dart';
import '../widgets/playback_date_picker_sheet.dart';
import '../widgets/playback_item_card/playback_item_card.dart';
import '../../../tracking/presentation/widgets/tracked_asset_gate.dart';

/// An asset's journey legs over a date range, opened by id.
///
/// Expects a TrackedAssetCubit (loaded by the route) and an
/// [PlaybackCubit] above it. The starting range comes from the link's
/// `?from=&to=`, already clamped to what the picker accepts.
class PlaybackPage extends StatelessWidget {
  const PlaybackPage({
    super.key,
    required this.assetId,
    required this.initialRange,
  });

  final String assetId;
  final PlaybackRange initialRange;

  @override
  Widget build(BuildContext context) => TrackedAssetGate(
    assetId: assetId,
    builder: (context, asset) =>
        _PlaybackView(asset: asset, initialRange: initialRange),
  );
}

class _PlaybackView extends StatefulWidget {
  const _PlaybackView({required this.asset, required this.initialRange});

  final TrackedAsset asset;
  final PlaybackRange initialRange;

  @override
  State<_PlaybackView> createState() => _PlaybackViewState();
}

class _PlaybackViewState extends State<_PlaybackView> {
  late DateTime _fromDate = widget.initialRange.from;
  late DateTime _toDate = widget.initialRange.to;
  bool _playingAll = false;
  int? _playingSegmentIndex;

  @override
  void initState() {
    super.initState();
    _loadSegments();
  }

  /// /The pickers are day-granular and inclusive, so the range sent is
  /// [from, to + 1 day).
  void _loadSegments() => context.read<PlaybackCubit>().load(
    assetId: widget.asset.id,
    from: _fromDate,
    to: _toDate.add(const Duration(days: 1)),
  );

  Future<void> _chooseDate({required bool isStart}) async {
    final l = AppLocalizations.of(context)!;
    final current = isStart ? _fromDate : _toDate;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      builder: (context) => PlaybackDatePickerSheet(
        title: l.playbackChooseDay,
        initialDate: current,
        // Whole days, from the same source the link parser clamps against.
        firstDate: PlaybackRange.earliest(DateUtils.dateOnly(DateTime.now())),
        lastDate: DateUtils.dateOnly(DateTime.now()),
      ),
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
    _loadSegments();
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

    final playbackTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: TrackingColors.of(context).playbackPrimary,
      ),
    );

    return Theme(
      data: playbackTheme,
      child: Scaffold(
        appBar: NasamAppBar(
          showLeading: false,
          toolbarHeight: 64.h,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.pop(),
            icon: IconTheme(
              data: IconThemeData(size: AppIconSize.medium.value.r),
              child: BackButtonIcon(),
            ),
          ),
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.assetPlaybackTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                joinIsolated([widget.asset.name, widget.asset.code], ' · '),
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
                child: AppButton(
                  label: _playingAll
                      ? l.assetPlaybackPause
                      : l.assetPlaybackStart,
                  onPressed: () {
                    //   _togglePlayback();
                    context.push(
                      AppRoutes.assetPlaybackMap(
                        widget.asset.id,
                        from: _fromDate,
                        to: _toDate,
                      ),
                    );
                  },
                  assetIcon: _playingAll? AppAssets.pauseIcon : AppAssets.playIcon,
                  height: kMinInteractiveDimension,
                  variant: AppButtonVariant.primary,
                  primaryBackgroundColor: TrackingColors.of(
                    context,
                  ).playbackPrimary,
                  labelStyle: TextStyle(fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: BlocBuilder<PlaybackCubit, PlaybackState>(
                  builder: (context, state) => switch (state) {
                    PlaybackLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    PlaybackFailure() => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.errorGeneric),
                          // TextButton(
                          //   onPressed: _loadSegments,
                          //   child: Text(l.retry),
                          // ),
                          AppButton(
                            onPressed: _loadSegments,
                            label: l.retry,
                            variant: AppButtonVariant.tertiary,
                          ),
                        ],
                      ),
                    ),
                    PlaybackLoaded(:final segments) when segments.isEmpty =>
                      Center(child: Text(l.assetPlaybackEmpty)),
                    PlaybackLoaded(:final segments) => ListView.separated(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        14.w,
                        4.h,
                        14.w,
                        16.h,
                      ),
                      itemCount: segments.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 7.h),
                      itemBuilder: (context, index) => PlaybackItemCard(
                        segment: segments[index],
                        locale: locale,
                        playing: _playingAll || _playingSegmentIndex == index,
                        onPlayPressed: () => _toggleSegment(index),
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
