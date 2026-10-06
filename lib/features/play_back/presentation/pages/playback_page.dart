import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_result_widget.dart';
import '../../../tracking/domain/entities/tracked_asset.dart';
import '../../../tracking/presentation/widgets/tracked_asset_gate.dart';
import '../cubit/playback_cubit.dart';
import '../cubit/playback_state.dart';
import '../utils/playback_range.dart';
import '../widgets/playback_appbar.dart';
import '../widgets/playback_date_picker_sheet.dart';
import '../widgets/playback_date_range_selector.dart';
import '../widgets/playback_item_card/playback_item_card.dart';

/// An asset's journey legs over a date range, opened by id.
///
/// Expects a TrackedAssetCubit (loaded by the route) and an
/// [PlaybackCubit] above it. The starting range comes from the link's
/// `?from=&to=`, already clamped to what the picker accepts.
class PlaybackPage extends StatefulWidget {
  const PlaybackPage({
    super.key,
    required this.assetId,
    required this.initialRange,
  });

  final String assetId;
  final PlaybackRange initialRange;

  @override
  State<PlaybackPage> createState() => PlaybackPageState();
}

class PlaybackPageState extends State<PlaybackPage> {
  late DateTime _fromDate = widget.initialRange.from;
  late DateTime _toDate = widget.initialRange.to;
  bool _playingAll = false;
  int? _playingSegmentIndex;
  TrackedAsset? _asset;
  String? _loadedAssetId;

  @override
  Widget build(BuildContext context) {
    return TrackedAssetGate(
      assetId: widget.assetId,
      builder: (context, asset) {
        _asset = asset;
        if (_loadedAssetId != asset.id) {
          _loadedAssetId = asset.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _loadedAssetId == asset.id) _loadSegments();
          });
        }
        return _buildPage(context, asset);
      },
    );
  }

  Widget _buildPage(BuildContext context, TrackedAsset asset) {
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
        appBar: PlaybackAppbar(asset: asset),
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
              Expanded(
                child: BlocBuilder<PlaybackCubit, PlaybackState>(
                  builder: (context, state) => switch (state) {
                    PlaybackLoading() => const Center(
                      child: LoadingIndicatorWidget(),
                    ),
                    PlaybackFailure(:final failure) => AppErrorWidget(
                      message: l.errorGeneric,
                      retryLabel: l.retry,
                      onRetry: _loadSegments,
                      type: AppErrorWidget.typeForFailure(failure),
                    ),
                    PlaybackLoaded(:final segments) when segments.isEmpty =>
                      EmptyResultWidget(
                        message: l.assetPlaybackEmpty,
                        type: EmptyResultType.playbackSegments,
                        retryLabel: l.retry,
                        onRetry: _loadSegments,
                      ),
                    PlaybackLoaded(:final segments) => Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: AppButton(
                            label: _playingAll
                                ? l.assetPlaybackPause
                                : l.assetPlaybackStart,
                            onPressed: () => context.push(
                              AppRoutes.assetPlaybackMap(
                                asset.id,
                                from: _fromDate,
                                to: _toDate,
                              ),
                            ),
                            assetIcon: _playingAll
                                ? AppAssets.pauseIcon
                                : AppAssets.playIcon,
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
                          child: ListView.separated(
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
                              playing:
                                  _playingAll || _playingSegmentIndex == index,
                              onPlayPressed: () => _toggleSegment(index),
                            ),
                          ),
                        ),
                      ],
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

  /// /The pickers are day-granular and inclusive, so the range sent is
  /// [from, to + 1 day).
  void _loadSegments() {
    final asset = _asset;
    if (asset == null) return;
    context.read<PlaybackCubit>().load(
      assetId: asset.id,
      from: _fromDate,
      to: _toDate.add(const Duration(days: 1)),
    );
  }

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

  void _toggleSegment(int index) => setState(() {
    _playingAll = false;
    _playingSegmentIndex = _playingSegmentIndex == index ? null : index;
  });
}
