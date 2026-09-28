import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/measure_size.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_state.dart';
import 'poi_icon.dart';

class PoiSummary extends StatelessWidget {
  const PoiSummary({
    super.key,
    required this.state,
    required this.scrollController,
    required this.searchController,
    required this.onSearch,
    required this.onToggle,
    required this.expanded,
    required this.onHeaderSize,
    required this.onSelect,
    required this.onActions,
    required this.onRetry,
    required this.onAdd,
    required this.onUpload,
    this.onDownload,
  });
  final PoiState state;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onToggle;
  final bool expanded;
  final ValueChanged<Size> onHeaderSize;
  final ValueChanged<PointOfInterest> onSelect;
  final ValueChanged<PointOfInterest> onActions;
  final VoidCallback onRetry;
  final VoidCallback onAdd, onUpload;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final points = state.visiblePoints;
    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.r32),
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: MeasureSize(
              onChange: onHeaderSize,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSizes.p16),
                    Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(AppSizes.r4),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.trackingPoi,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: onToggle,
                          child: Text(expanded ? l.poiHide : l.trackingShow),
                        ),
                      ],
                    ),
                    AppTextField(
                      controller: searchController,
                      hint: l.trackingSearch,
                      prefixIcon: const Icon(Icons.search),
                      onChanged: onSearch,
                      suffixIcon: state.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l.drawerClearSearch,
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                searchController.clear();
                                onSearch('');
                              },
                            ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked =
                            constraints.maxWidth < 340 ||
                            MediaQuery.textScalerOf(context).scale(1) > 1.2;
                        final add = AppButton(
                          onPressed: onAdd,
                          label: l.poiAdd,
                          icon: Icons.add,
                          height: 48,
                        );
                        final transfers = Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                onPressed: onUpload,
                                label: l.poiUpload,
                                variant: AppButtonVariant.secondary,
                                height: 48,
                              ),
                            ),
                            const SizedBox(width: AppSizes.p4),
                            Expanded(
                              child: AppButton(
                                onPressed: onDownload,
                                label: l.poiDownload,
                                variant: AppButtonVariant.secondary,
                                height: 48,
                              ),
                            ),
                          ],
                        );
                        return stacked
                            ? Column(
                                children: [
                                  add,
                                  const SizedBox(height: AppSizes.p8),
                                  transfers,
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: transfers),
                                  const SizedBox(width: AppSizes.p12),
                                  Expanded(child: add),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),
                  ],
                ),
              ),
            ),
          ),
          if (state.status == PoiStatus.loading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          if (state.status == PoiStatus.failure)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  children: [
                    Text(l.errorGeneric),
                    TextButton(onPressed: onRetry, child: Text(l.retry)),
                  ],
                ),
              ),
            ),
          if (state.status != PoiStatus.loading &&
              state.status != PoiStatus.initial &&
              points.isEmpty &&
              state.status != PoiStatus.failure)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Text(
                  state.query.isEmpty ? l.poiEmpty : l.poiNoResults,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            sliver: SliverList.builder(
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  key: ValueKey('poi-row-${point.id}'),
                  contentPadding: EdgeInsets.zero,
                  selected: point.id == state.selectedId,
                  selectedTileColor: scheme.primaryContainer.withValues(
                    alpha: .3,
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    padding: const EdgeInsets.all(AppSizes.p8),
                    child: PoiIconImage(
                      icon: point.icon,
                      color: scheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    point.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    tooltip: l.poiActions,
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () => onActions(point),
                  ),
                  onTap: () => onSelect(point),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + AppSizes.p16,
            ),
          ),
        ],
      ),
    );
  }
}
