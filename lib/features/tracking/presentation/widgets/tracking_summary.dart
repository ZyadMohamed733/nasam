import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../../../shared/widgets/map_sheet_header.dart';
import '../../../../shared/widgets/measure_size.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../cubit/tracking_cubit.dart';
import '../utils/tracking_style.dart';
import 'tracking_asset_list.dart';

/// The fleet sheet: a handle, the title with its toggle, the status chips,
/// then the asset list — all in the sheet's one scroll view.
///
/// Everything scrolls together, handle included, so the sheet is dragged by
/// [DraggableScrollableSheet] itself; nothing here handles a drag. And
/// because nothing is laid out in a fixed-height column, no text scale or
/// screen size can overflow it: at worst the collapsed sheet shows less.
///
/// Holds no state of its own. The selected status and the search live in
/// [TrackingCubit]; the search text's controller in the page.
class TrackingSummary extends StatelessWidget {
  const TrackingSummary({
    super.key,
    required this.state,
    required this.expanded,
    required this.scrollController,
    required this.searchController,
    required this.searchFocusNode,
    required this.onToggle,
    required this.onHeaderSize,
    required this.onClearFilters,
  });
  final TrackingLoaded state;
  final bool expanded;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onToggle;

  /// The header's laid-out height — what the collapsed sheet must show.
  final ValueChanged<Size> onHeaderSize;
  final VoidCallback onClearFilters;

  /// Horizontal inset of the sheet's content.
  static const double gutter = 16;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<TrackingCubit>();
    final selectedStatus = state.filter;
    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: MeasureSize(
              onChange: onHeaderSize,
              child: _Header(
                expanded: expanded,
                onToggle: onToggle,
                chips: [
                  _StatusChip(
                    label: l.trackingAll,
                    count: state.vehicles.length,
                    color: TrackingColors.of(context).accent,
                    selected: selectedStatus == null,
                    onTap: () => cubit.setFilter(null),
                  ),
                  for (final status in VehicleStatus.values)
                    _StatusChip(
                      label: TrackingStyle.label(l, status),
                      count: state.count(status),
                      color: TrackingStyle.status(context, status),
                      status: status,
                      selected: selectedStatus == status,
                      onTap: () => cubit.setFilter(status),
                    ),
                ],
              ),
            ),
          ),
          SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 28),
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: gutter),
              sliver: TrackingAssetList(
                title: selectedStatus == null
                    ? l.trackingAll
                    : TrackingStyle.label(l, selectedStatus),
                assets: state.visibleAssets,
                searchController: searchController,
                searchFocusNode: searchFocusNode,
                onQueryChanged: cubit.onQueryChanged,
                filtered: selectedStatus != null || state.query.isNotEmpty,
                onClearFilters: onClearFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.expanded,
    required this.onToggle,
    required this.chips,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MapSheetHeader(
          // 12 above the bar and 16 below it, as tracking has always drawn it.
          handle: MapSheetHandle(color: scheme.outline, height: 12 + 3 + 16),
          title: l.trackingTitle,
          titleStyle: Theme.of(context).textTheme.titleMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: TrackingSummary.gutter,
          ),
          action: expanded
              ? IconButton(
                  onPressed: onToggle,
                  tooltip: l.trackingCollapse,
                  icon: Icon(Icons.close, size: AppIconSize.medium.value),
                )
              : TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: TrackingColors.of(context).accent,
                  ),
                  child: Text(l.trackingShow),
                ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: TrackingSummary.gutter,
          ),
          child: Row(children: chips),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A status filter. The visible chip is compact; its hit target is the full
/// 48dp the platform guidelines ask for.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
    this.status,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  /// Null for "all".
  final VehicleStatus? status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final radius = BorderRadius.circular(8);
    final status = this.status;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5),
      child: Semantics(
        button: true,
        selected: selected,
        label: l.trackingStatusChip(label, count),
        // excludeSemantics drops the InkWell's tap action along with its
        // text, so the action is declared here or a screen reader cannot
        // activate the chip at all.
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .07),
                  borderRadius: radius,
                  border: selected
                      ? Border.all(color: color.withValues(alpha: .25))
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == null)
                        SvgPicture.asset(
                          AppAssets.mapArrow,
                          width: AppIconSize.small.value,
                          height: AppIconSize.small.value,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        )
                      else
                        Icon(
                          TrackingStyle.icon(status),
                          size: AppIconSize.small.value,
                          color: color,
                        ),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(fontSize: 11, color: color)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: .3),
                          ),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(fontSize: 11, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
