import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../../../core/utils/bidi.dart';
import '../../../../features/tracking/domain/entities/tracked_asset.dart';
import '../../../../features/tracking/presentation/utils/tracking_units.dart';
import '../../domain/entities/playback_point.dart';
import '../cubit/playback_map_cubit.dart';

class PlaybackInfoBottomSheet extends StatelessWidget {
  const PlaybackInfoBottomSheet({super.key, required this.asset});

  final TrackedAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final assetCode = joinIsolated([asset.code, asset.name], ' · ');
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSizes.p16,
              AppSizes.p8,
              AppSizes.p16,
              AppSizes.p12,
            ),
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                SizedBox(height: AppSizes.p12.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.assetPlaybackTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          assetCode,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
              builder: (context, state) {
                if (state is! PlaybackMapLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                final point =
                    state.points[state.currentIndex.clamp(
                      0,
                      state.points.length - 1,
                    )];
                return _PlaybackInfoContent(point: point);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackInfoContent extends StatelessWidget {
  const _PlaybackInfoContent({required this.point});

  final PlaybackPoint point;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final units = TrackingUnits.of(context);
    final locale = Localizations.localeOf(context).toString();
    final timestamp = DateFormat.yMMMMd(
      locale,
    ).add_jm().format(point.recordedAt);
    final trackingColors = TrackingColors.of(context);

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSizes.p16,
        0,
        AppSizes.p16,
        MediaQuery.paddingOf(context).bottom + AppSizes.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(l.playbackInfoAssetInformation),
          _InfoCell(label: l.playbackInfoDate, value: timestamp),
          SizedBox(height: AppSizes.p8.h),
          _InfoPair(
            right: _InfoCell(
              label: l.assetDetailsSpeed,
              value: units.speedKph(point.speedKph),
            ),
            left: _InfoCell(
              label: l.playbackInfoStatus,
              value: point.isMoving ? l.playbackInfoMoving : l.trackingStopped,
              valueColor: point.isMoving
                  ? trackingColors.moving
                  : trackingColors.stopped,
            ),
          ),
          SizedBox(height: AppSizes.p8.h),
          _InfoPair(
            right: _InfoCell(
              label: l.playbackInfoIgnition,
              value: point.engineOn
                  ? l.playbackInfoIgnitionOn
                  : l.playbackInfoIgnitionOff,
              valueColor: point.engineOn
                  ? trackingColors.moving
                  : trackingColors.stopped,
            ),
            left: _InfoCell(
              label: l.playbackInfoOdometer,
              value: units.distanceKm(point.distanceOdometerKm),
            ),
          ),
          SizedBox(height: AppSizes.p8.h),
          _InfoCell(
            label: l.playbackInfoLocation,
            value: Localizations.localeOf(context).languageCode == 'ar'
                ? point.locationAr
                : point.locationEn,
          ),
          SizedBox(height: AppSizes.p12.h),
          _SectionTitle(l.playbackInfoSensors),
          _InfoPair(
            right: _InfoCell(
              label: l.playbackInfoFuelLevel,
              value: units.percent(point.fuelLevelPercent),
            ),
            left: _InfoCell(
              label: l.assetDetailsTemperature,
              value: units.celsius(point.temperatureCelsius),
            ),
          ),
          SizedBox(height: AppSizes.p8.h),
          _InfoPair(
            right: _InfoCell(
              label: l.playbackInfoHumidity,
              value: units.percent(point.humidityPercent),
            ),
            left: _InfoCell(
              label: l.assetDetailsWeight,
              value: units.weightKg(point.weightKg),
            ),
          ),
          SizedBox(height: AppSizes.p16.h),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: AppSizes.p8.h),
    child: Text(title, style: Theme.of(context).textTheme.labelMedium),
  );
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.right, required this.left});

  final Widget right;
  final Widget left;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: right),
      SizedBox(width: AppSizes.p8.w),
      Expanded(child: left),
    ],
  );
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minHeight: 52.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? scheme.onSurface,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
