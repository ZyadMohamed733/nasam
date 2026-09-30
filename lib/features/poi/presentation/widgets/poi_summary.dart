import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/poi_sheet_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/hit_target.dart';
import '../../../../shared/widgets/map_sheet_header.dart';
import '../../../../shared/widgets/measure_size.dart';
import '../../domain/entities/point_of_interest.dart';
import '../cubit/poi_state.dart';
import 'poi_list_row.dart';
import 'poi_sheet_layout.dart';

/// The POI sheet (`647:8266`): handle, title with its show/close action,
/// search, the add/upload/download buttons, then the list — all in the
/// sheet's one scroll view, so [DraggableScrollableSheet] drags it.
///
/// [onHeaderSize] reports everything above the list: what the collapsed
/// sheet shows above its [PoiSheetLayout.sheetBottomPadding].
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

  /// The drawn header action and buttons, for tests that measure them.
  static const headerActionKey = ValueKey('poi-summary-header-action');
  static const addKey = ValueKey('poi-summary-add');
  static const uploadKey = ValueKey('poi-summary-upload');
  static const downloadKey = ValueKey('poi-summary-download');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final colors = PoiSheetColors.of(context);
    final points = state.visiblePoints;
    final bottom =
        PoiSheetLayout.sheetBottomPadding +
        MediaQuery.paddingOf(context).bottom;
    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(PoiSheetLayout.sheetRadius),
      ),
      child: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: MeasureSize(
                  onChange: onHeaderSize,
                  child: HitTargetScope(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MapSheetHeader(
                          handle: MapSheetHandle(
                            color: colors.handle,
                            height: PoiSheetLayout.handleArea,
                            barTop: PoiSheetLayout.handleBarTop,
                            barSize: PoiSheetLayout.handleBar,
                          ),
                          title: l.trackingPoi,
                          titleStyle: context.textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w400,
                                height: PoiSheetLayout.titleLineHeight,
                              ),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            PoiSheetLayout.gutter,
                            PoiSheetLayout.contentTop,
                            PoiSheetLayout.gutter,
                            0,
                          ),
                          minRowHeight: PoiSheetLayout.titleRowHeight,
                          action: HitTargetExtender(
                            child: _HeaderAction(
                              expanded: expanded,
                              onToggle: onToggle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height:
                              PoiSheetLayout.titleToSearch -
                              PoiSheetLayout.searchTapInset,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PoiSheetLayout.gutter,
                          ),
                          child: AppTextField.search(
                            controller: searchController,
                            hint: l.trackingSearch,
                            onChanged: onSearch,
                            clearTooltip: l.drawerClearSearch,
                            searchColors: AppSearchFieldColors(
                              fill: colors.searchFill,
                              border: colors.searchBorder,
                              icon: colors.searchIcon,
                              text: colors.searchText,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height:
                              PoiSheetLayout.searchToButtons -
                              PoiSheetLayout.searchTapInset,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PoiSheetLayout.gutter,
                          ),
                          child: _Buttons(
                            onAdd: onAdd,
                            onUpload: onUpload,
                            onDownload: onDownload,
                          ),
                        ),
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
              SliverList.builder(
                itemCount: points.length,
                itemBuilder: (context, index) {
                  final point = points[index];
                  return PoiListRow(
                    key: ValueKey('poi-row-${point.id}'),
                    point: point,
                    selected: point.id == state.selectedId,
                    onSelect: () => onSelect(point),
                    onActions: () => onActions(point),
                  );
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottom)),
            ],
          ),
          // The sheet's bottom padding. The list scrolls under it, the way
          // the design's frame clips its list above the padding — so the
          // collapsed sheet ends in blank space, not in a cut-off row.
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            height: bottom,
            child: ColoredBox(color: scheme.surface),
          ),
        ],
      ),
    );
  }
}

/// "Show" while collapsed, a close icon while open, in the design's 33×20
/// link-button box at the header's end.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = PoiSheetColors.of(context);
    final Widget content = expanded
        ? SvgPicture.asset(
            AppAssets.poiClose,
            width: PoiSheetLayout.headerIcon,
            height: PoiSheetLayout.headerIcon,
            colorFilter: ColorFilter.mode(colors.icon, BlendMode.srcIn),
            excludeFromSemantics: true,
          )
        : Text(
            l.trackingShow,
            maxLines: 1,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.link,
              height: PoiSheetLayout.titleLineHeight,
            ),
          );
    final action = Semantics(
      button: true,
      child: InkResponse(
        onTap: onToggle,
        radius: PoiSheetLayout.tapTarget / 2,
        child: ConstrainedBox(
          key: PoiSummary.headerActionKey,
          constraints: BoxConstraints(
            minWidth: PoiSheetLayout.headerAction.width,
            minHeight: PoiSheetLayout.headerAction.height,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: 1,
            heightFactor: 1,
            child: content,
          ),
        ),
      ),
    );
    return expanded ? Tooltip(message: l.poiHide, child: action) : action;
  }
}

/// The add, upload and download buttons (`647:8283`): the transfer pair on
/// the start half, add on the end half — or stacked, add first, where a row
/// would not fit.
class _Buttons extends StatelessWidget {
  const _Buttons({
    required this.onAdd,
    required this.onUpload,
    required this.onDownload,
  });

  final VoidCallback onAdd, onUpload;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = context.textTheme.labelMedium?.copyWith(
      height: PoiSheetLayout.titleLineHeight,
    );
    final iconColor = context.semanticColors.iconSecondary;

    Widget button({
      required Key key,
      required String text,
      required VoidCallback? onPressed,
      AppButtonVariant variant = AppButtonVariant.secondary,
      String? asset,
      IconData? icon,
    }) => HitTargetExtender(
      child: AppButton(
        key: key,
        onPressed: onPressed,
        label: text,
        variant: variant,
        assetIcon: asset,
        icon: icon,
        iconSize: PoiSheetLayout.buttonIcon,
        iconColor: variant == AppButtonVariant.secondary ? iconColor : null,
        height: PoiSheetLayout.buttonHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: PoiSheetLayout.buttonPaddingH,
        ),
        labelStyle: label,
      ),
    );

    final add = button(
      key: PoiSummary.addKey,
      text: l.poiAdd,
      onPressed: onAdd,
      variant: AppButtonVariant.primary,
      icon: Icons.add,
    );
    final transfers = Row(
      children: [
        Expanded(
          child: button(
            key: PoiSummary.uploadKey,
            text: l.poiUpload,
            onPressed: onUpload,
            asset: AppAssets.poiUpload,
          ),
        ),
        const SizedBox(width: PoiSheetLayout.buttonGap),
        Expanded(
          child: button(
            key: PoiSummary.downloadKey,
            text: l.poiDownload,
            onPressed: onDownload,
            asset: AppAssets.poiImport,
          ),
        ),
      ],
    );
    Widget band(Widget child) => SizedBox(
      height: PoiSheetLayout.buttonRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoiSheetLayout.buttonInset,
        ),
        child: Center(child: child),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < PoiSheetLayout.stackBelowWidth ||
            MediaQuery.textScalerOf(context).scale(1) >
                PoiSheetLayout.stackAboveTextScale;
        if (stacked) {
          return Column(children: [band(add), band(transfers)]);
        }
        return band(
          Row(
            children: [
              Expanded(child: transfers),
              const SizedBox(width: PoiSheetLayout.buttonGap),
              Expanded(child: add),
            ],
          ),
        );
      },
    );
  }
}
