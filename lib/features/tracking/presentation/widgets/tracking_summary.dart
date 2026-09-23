import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../cubit/tracking_cubit.dart';
import '../pages/tracking_assets_page.dart';
import '../tracking_style.dart';

/// The fleet sheet: status chips over the asset list.
///
/// Holds no state of its own. The selected status and the search text live in
/// [TrackingCubit], so they survive a refresh and the sheet being rebuilt.
class TrackingSummary extends StatelessWidget {
  const TrackingSummary({
    super.key,
    required this.state,
    required this.expanded,
    required this.scrollController,
    required this.sheetController,
    required this.minSheetExtent,
    required this.maxSheetExtent,
    required this.onShowTap,
  });
  final TrackingLoaded state;
  final bool expanded;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final double minSheetExtent;
  final double maxSheetExtent;
  final VoidCallback onShowTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<TrackingCubit>();
    final selectedStatus = state.filter;
    final selectedLabel = selectedStatus == null
        ? l.trackingAll
        : TrackingStyle.label(l, selectedStatus);
    final selectedPage = TrackingAssetsPage(
      title: selectedLabel,
      assets: state.visibleAssets,
      onQueryChanged: cubit.onQueryChanged,
    );
    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (!sheetController.isAttached) return;
                  final screenHeight = MediaQuery.sizeOf(context).height;
                  final nextExtent = (sheetController.size -
                          details.delta.dy / screenHeight)
                      .clamp(minSheetExtent, maxSheetExtent)
                      .toDouble();
                  sheetController.jumpTo(nextExtent);
                },
                onVerticalDragEnd: (_) {
                  if (!sheetController.isAttached) return;
                  sheetController.animateTo(
                    sheetController.size <
                            (minSheetExtent + maxSheetExtent) / 2
                        ? minSheetExtent
                        : maxSheetExtent,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 3,
                        decoration: BoxDecoration(
                          color: scheme.outline,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        l.trackingTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  //

                    InkWell(
                      onTap: onShowTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: expanded?   Icon(
                         // onPressed: onShowTap,

                        Icons.close, size: AppIconSize.medium.value.r,
                        ):Text(
                          l.trackingShow,
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                    ),
                ],
              ),
                AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _chip(
                              context,
                              l.trackingAll,
                              state.vehicles.length,
                              scheme.primary,
                              null,
                              selectedStatus == null,
                                  () => cubit.setFilter(null),
                            ),
                            for (final status in VehicleStatus.values)
                              _chip(
                                context,
                                TrackingStyle.label(l, status),
                                state.count(status),
                                TrackingStyle.status(context, status),
                                status,
                                selectedStatus == status,
                                    () => cubit.setFilter(status),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: selectedPage,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

// test
  Widget _chip(
      BuildContext context,
      String label,
      int count,
      Color color,
      VehicleStatus? status,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: .01),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Material(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: color.withValues(alpha: .25))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == null)
                    SvgPicture.asset(
                      AppAssets.mapArrow,
                      width: AppIconSize.small.value.r,
                      height: AppIconSize.small.value.r,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    )
                  else
                    Icon(
                      switch (status) {
                        VehicleStatus.moving => Icons.check,
                        VehicleStatus.idle => Icons.schedule,
                        VehicleStatus.stopped => Icons.local_parking,
                        VehicleStatus.offline => Icons.power_off_outlined,
                      },
                      size: AppIconSize.small.value.r,
                      color: color,
                    ),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontSize: 11, color: color)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: .3)),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(fontSize: 9, color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
