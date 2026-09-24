import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../cubit/tracking_cubit.dart';
import '../tracking_style.dart';
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
    required this.onToggle,
    required this.onHeaderSize,
    required this.onClearFilters,
  });
  final TrackingLoaded state;
  final bool expanded;
  final ScrollController scrollController;
  final TextEditingController searchController;
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
            child: _MeasureSize(
              onChange: onHeaderSize,
              child: _Header(
                expanded: expanded,
                onToggle: onToggle,
                chips: [
                  _StatusChip(
                    label: l.trackingAll,
                    count: state.vehicles.length,
                    color: scheme.primary,
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The drag handle. Decorative: the whole sheet drags, and the
          // toggle below is the accessible way to open and close it.
          Center(
            child: Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TrackingSummary.gutter,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.trackingTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (expanded)
                  IconButton(
                    onPressed: onToggle,
                    tooltip: l.trackingCollapse,
                    icon: Icon(Icons.close, size: AppIconSize.medium.value),
                  )
                else
                  TextButton(
                    onPressed: onToggle,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(l.trackingShow),
                  ),
              ],
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
      ),
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

/// Reports its child's laid-out size after each layout that changes it.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) => renderObject.onChange = onChange;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final size = this.size;
    if (size == _reported) return;
    _reported = size;
    // Reported after the frame: the listener rebuilds, which cannot happen
    // during layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(size));
  }
}
