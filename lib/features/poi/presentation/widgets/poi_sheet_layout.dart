import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// The POI sheet's geometry, read from the "POI – open" component (`647:8266`)
/// and its row (`507:16775`) in `design_exports/nasam_mobile_2/poi_nodes.json`.
///
/// Every control drawn smaller than [tapTarget] keeps its drawn size and gets
/// a [tapTarget]-square touch target through a `HitTargetExtender`; the
/// search field and the row insets below account for that where it is laid
/// out rather than extended.
abstract final class PoiSheetLayout {
  static const double tapTarget = kMinInteractiveDimension;

  // Sheet (647:8266).
  static const double sheetRadius = 32;
  static const double sheetBottomPadding = 16;

  // Drag handle (175:4141): the bar is pinned 12 from the strip's top.
  static const double handleArea = 34;
  static const double handleBarTop = 12;
  static const Size handleBar = Size(56, 3);

  // Content (647:8268 "Wrap").
  static const double gutter = 16;
  static const double contentTop = 16;

  // Header (647:8270).
  static const double titleRowHeight = 24;
  static const double titleLineHeight = 1.3;

  /// The link button (`647:8271`), drawn at the row's end; the close icon
  /// takes the same box.
  static const Size headerAction = Size(33, 20);
  static const double headerIcon = 16;

  // Search (647:8274).
  static const double titleToSearch = 8;
  static const double searchHeight = AppSizes.searchFieldHeight;
  static const double searchRadius = AppSizes.searchFieldRadius;

  /// Half the difference between the search's touch target and its box: the
  /// field lays out that much taller on each side than it draws.
  static const double searchTapInset = (tapTarget - searchHeight) / 2;

  // Buttons (647:8283 "all"). The frame is a fixed 54 with the 40-tall
  // buttons centred, so 7 above and below — its 12 vertical padding is
  // overridden by that fixed height.
  static const double searchToButtons = 4;
  static const double buttonRowHeight = 54;
  static const double buttonInset = 4;
  static const double buttonGap = 4;
  static const double buttonHeight = 40;
  static const double buttonIcon = 16;

  /// Inside each button (14:357, 14:363), either side of its content.
  static const double buttonPaddingH = 4;

  /// Below this width, or above [stackAboveTextScale], the primary button
  /// takes a row of its own above the transfer pair.
  static const double stackBelowWidth = 340;
  static const double stackAboveTextScale = 1.2;

  // List (647:8288).
  static const double listGap = 4;
  static const double rowGap = 8;

  /// Around each row: the gutter, and half the gap above and below. The first
  /// row's half-gap is the design's 4 under the buttons.
  static const EdgeInsets rowMargin = EdgeInsets.symmetric(
    horizontal: gutter,
    vertical: rowGap / 2,
  );

  // Row (507:16775, overridden in 647:8289).
  static const double rowHeight = 44;
  static const double rowPaddingH = 12;
  static const double rowPaddingV = 4;
  static const double rowRadius = 8;
  static const double iconBox = 36;
  static const double iconBoxRadius = 8;
  static const double rowIcon = 20;
  static const double iconToName = 10;
  static const double menuIcon = 16;

  /// Kept clear between the name and the menu dots. The design spaces the
  /// two frames apart with room to spare; this is where a long name stops.
  static const double nameToMenu = 8;
}
