import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/tracking_colors.dart';
import '../../../../../shared/widgets/action_icon.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../cubit/playback_map_cubit.dart';
import '../../cubit/playback_map_state.dart';

class PanelWidget extends StatelessWidget {
  const PanelWidget({
    super.key,
    required this.from,
    required this.to,
    required this.onPick,
    required this.onLoad,
  });

  final DateTime from;
  final DateTime to;
  final VoidCallback onPick;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackMapCubit, PlaybackMapState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final loaded = state is PlaybackMapLoaded ? state : null;
        final l = AppLocalizations.of(context)!;

        return Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSizes.p16,
            AppSizes.p16,
            AppSizes.p16,
            MediaQuery.paddingOf(context).bottom + AppSizes.p8,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.r24),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: .12),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onPick,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: AppSizes.iconSm,
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        child: Text(
                          '${_dateFormat(context).format(from)} - ${_dateFormat(context).format(to)}',
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              if (state is PlaybackMapLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSizes.p8),
                  child: CircularProgressIndicator(),
                )
              else if (state is PlaybackMapFailure)
                Row(
                  children: [
                    Expanded(child: Text(l.errorGeneric)),
                    SizedBox(
                      width: 104,
                      child: AppButton(
                        onPressed: onLoad,
                        label: l.retry,
                        variant: AppButtonVariant.tertiary,
                      ),
                    ),
                  ],
                )
              else if (state is PlaybackMapEmpty)
                  Text(l.assetPlaybackEmpty)
                else if (loaded != null) ...[
                    _scrubber(context, loaded),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      textDirection: ui.TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppAssetsIconWidget(
                          label: l.playbackPrevious,
                          onPressed: context.read<PlaybackMapCubit>().previous,
                          asset: AppAssets.skipPrevious,
                          size: AppSizes.iconSm,
                          boxDecoration: BoxDecoration(
                            color: TrackingColors.of(context)
                                .playbackPrimary
                                .withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        AppAssetsIconWidget(
                          asset: loaded.isPlaying
                              ? AppAssets.pauseIcon
                              : AppAssets.playIcon,
                          label: loaded.isPlaying
                              ? l.assetPlaybackPause
                              : l.assetPlaybackPlay,
                          onPressed: context.read<PlaybackMapCubit>().toggle,
                          containerSize: 46,
                          size: AppSizes.iconSm,
                          boxDecoration: BoxDecoration(
                            color: TrackingColors.of(context).playbackPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        AppAssetsIconWidget(
                          asset: AppAssets.skipNext,
                          label: l.playbackNext,
                          onPressed: context.read<PlaybackMapCubit>().next,
                          size: AppSizes.iconSm,
                          boxDecoration: BoxDecoration(
                            color: TrackingColors.of(context)
                                .playbackPrimary
                                .withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                      ],
                    ),
                  ],
            ],
          ),
        );
      },
    );
  }

  DateFormat _dateFormat(BuildContext context) => DateFormat.yMMMMd(
    Localizations.localeOf(context).toString(),
  ).add_jm();

  Widget _scrubber(BuildContext context, PlaybackMapLoaded state) {
    final points = state.points;
    final start = points.first.recordedAt;
    final end = points.last.recordedAt;
    final playbackColor = TrackingColors.of(context).playbackPrimary;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: playbackColor,
            thumbColor: playbackColor,
            inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          ),
          child: Slider(
            value: state.currentIndex.toDouble(),
            min: 0,
            max: (points.length - 1).toDouble(),
            onChanged: (value) =>
                context.read<PlaybackMapCubit>().seek(value.round()),
            semanticFormatterCallback: (value) => DateFormat.Hm().format(
              points[value.round().clamp(0, points.length - 1)].recordedAt,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.Hm().format(start),
              semanticsLabel: '',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: playbackColor),
            ),
            Text(
              DateFormat.Hm().format(end),
              semanticsLabel: '',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: playbackColor),
            ),
          ],
        ),
      ],
    );
  }
}
