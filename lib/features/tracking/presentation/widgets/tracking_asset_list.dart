import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/tracking_colors.dart';
import '../../domain/entities/tracked_asset.dart';
import 'tracking_asset_card.dart';
import 'tracking_asset_search_field.dart';

/// The fleet sheet's search field and asset cards, as slivers.
///
/// A sliver group rather than a column so it lives in the sheet's own
/// scroll view: cards are built as they scroll into view, and dragging the
/// list is what drags the sheet.
///
/// Renders what it is given. Filtering and search belong to `TrackingCubit`.
class TrackingAssetList extends StatelessWidget {
  const TrackingAssetList({
    super.key,
    required this.title,
    required this.assets,
    required this.searchController,
    required this.searchFocusNode,
    required this.onQueryChanged,
    required this.filtered,
    required this.onClearFilters,
  });

  /// Names the list for screen readers: the selected status.
  final String title;

  /// Already narrowed by the selected status and the committed search.
  final List<TrackedAsset> assets;

  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  /// Every keystroke; the cubit debounces.
  final ValueChanged<String> onQueryChanged;

  /// Whether a status or a search is narrowing [assets]; an empty result
  /// then offers to clear them rather than just saying there is nothing.
  final bool filtered;

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: TrackingAssetSearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              onChanged: onQueryChanged,
            ),
          ),
        ),
        if (assets.isEmpty)
          SliverToBoxAdapter(
            child: _NoMatches(
              filtered: filtered,
              onClearFilters: onClearFilters,
            ),
          )
        else
          SliverSemantics(
            container: true,
            label: title,
            sliver: SliverList.builder(
              itemCount: assets.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: TrackingAssetCard(asset: assets[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.filtered, required this.onClearFilters});

  final bool filtered;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Text(
            filtered ? l.trackingNoMatches : l.emptyState,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (filtered) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onClearFilters,
              style: TextButton.styleFrom(
                foregroundColor: TrackingColors.of(context).accent,
              ),
              child: Text(l.trackingClearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
