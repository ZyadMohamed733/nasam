import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/tracking_vehicle.dart';
import '../cubit/tracking_cubit.dart';
import '../pages/tracking_assets_page.dart';
import '../tracking_style.dart';

class TrackingSummary extends StatefulWidget {
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
  final TrackingState state;
  final bool expanded;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final double minSheetExtent;
  final double maxSheetExtent;
  final VoidCallback onShowTap;

  @override
  State<TrackingSummary> createState() => _TrackingSummaryState();
}

class _TrackingSummaryState extends State<TrackingSummary> {
  VehicleStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final selectedLabel = _selectedStatus == null
        ? l.trackingAll
        : TrackingStyle.label(l, _selectedStatus!);
    final selectedPage = TrackingAssetsPage(
      title: selectedLabel,
      status: _selectedStatus,
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
                  if (!widget.sheetController.isAttached) return;
                  final screenHeight = MediaQuery.sizeOf(context).height;
                  final nextExtent = (widget.sheetController.size -
                          details.delta.dy / screenHeight)
                      .clamp(widget.minSheetExtent, widget.maxSheetExtent)
                      .toDouble();
                  widget.sheetController.jumpTo(nextExtent);
                },
                onVerticalDragEnd: (_) {
                  if (!widget.sheetController.isAttached) return;
                  widget.sheetController.animateTo(
                    widget.sheetController.size <
                            (widget.minSheetExtent + widget.maxSheetExtent) / 2
                        ? widget.minSheetExtent
                        : widget.maxSheetExtent,
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
                      onTap: widget.onShowTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: widget.expanded?   Icon(
                         // onPressed: widget.onShowTap,

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
                              widget.state.vehicles.length,
                              scheme.primary,
                              null,
                              _selectedStatus == null,
                                  () => _showStatus(null),
                            ),
                            for (final status in VehicleStatus.values)
                              _chip(
                                context,
                                TrackingStyle.label(l, status),
                                widget.state.count(status),
                                TrackingStyle.status(context, status),
                                status,
                                _selectedStatus == status,
                                    () => _showStatus(status),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: selectedPage,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  void _showStatus(VehicleStatus? status) =>
      setState(() => _selectedStatus = status);
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
