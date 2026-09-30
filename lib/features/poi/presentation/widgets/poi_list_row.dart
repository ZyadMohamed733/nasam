import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/poi_sheet_colors.dart';
import '../../../../shared/widgets/hit_target.dart';
import '../../domain/entities/point_of_interest.dart';
import 'poi_icon.dart';
import 'poi_sheet_layout.dart';

/// One point in the POI sheet's list (`507:16775`): the icon box and name at
/// the start, the actions menu at the end.
///
/// Draws 44 tall. The row and its menu each answer touches across 48, so the
/// widget lays out with [margin] around the drawn row — the gutter and half
/// the gap to the next row — to hold those targets.
class PoiListRow extends StatelessWidget {
  const PoiListRow({
    super.key,
    required this.point,
    required this.selected,
    required this.onSelect,
    required this.onActions,
    this.margin = PoiSheetLayout.rowMargin,
  });

  final PointOfInterest point;

  /// NOT IN THE DESIGN: the design has no selected row. See docs/backlog.md.
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onActions;
  final EdgeInsetsGeometry margin;

  /// The drawn row and its icon box, for tests that measure them.
  static const rowKey = ValueKey('poi-list-row');
  static const iconBoxKey = ValueKey('poi-list-row-icon-box');

  @override
  Widget build(BuildContext context) {
    final colors = PoiSheetColors.of(context);
    // The border is the shape's, drawn inside the edge like the design's
    // stroke, so it takes no room from the 36 content.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PoiSheetLayout.rowRadius),
      side: BorderSide(color: colors.rowBorder),
    );
    return HitTargetScope(
      child: Padding(
        padding: margin,
        child: Stack(
          children: [
            HitTargetExtender(
              child: Semantics(
                button: true,
                selected: selected,
                child: Material(
                  key: rowKey,
                  color: selected ? colors.rowSelectedFill : colors.rowFill,
                  shape: shape,
                  child: SizedBox(
                    height: PoiSheetLayout.rowHeight,
                    child: InkWell(
                      onTap: onSelect,
                      customBorder: shape,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: PoiSheetLayout.rowPaddingH,
                          end:
                              PoiSheetLayout.rowPaddingH +
                              PoiSheetLayout.menuIcon +
                              PoiSheetLayout.nameToMenu,
                          top: PoiSheetLayout.rowPaddingV,
                          bottom: PoiSheetLayout.rowPaddingV,
                        ),
                        child: Row(
                          children: [
                            Container(
                              key: iconBoxKey,
                              width: PoiSheetLayout.iconBox,
                              height: PoiSheetLayout.iconBox,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.iconBoxFill,
                                borderRadius: BorderRadius.circular(
                                  PoiSheetLayout.iconBoxRadius,
                                ),
                              ),
                              child: PoiIconImage(
                                icon: point.icon,
                                color: colors.iconBoxIcon,
                                size: PoiSheetLayout.rowIcon,
                              ),
                            ),
                            const SizedBox(width: PoiSheetLayout.iconToName),
                            Expanded(
                              child: Text(
                                point.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: colors.rowText),
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
            // Over the row, so its target takes the row's touches near it.
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: PoiSheetLayout.rowPaddingH,
              child: Center(
                widthFactor: 1,
                child: HitTargetExtender(
                  child: _MenuButton(
                    tooltip: AppLocalizations.of(context)!.poiActions,
                    color: colors.icon,
                    onPressed: onActions,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The vertical three dots (`507:16779`), drawn 16 square.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkResponse(
      onTap: onPressed,
      radius: PoiSheetLayout.tapTarget / 2,
      child: SizedBox.square(
        dimension: PoiSheetLayout.menuIcon,
        child: Center(
          // The asset is the 4×13 glyph at the design's 16 scale.
          child: SvgPicture.asset(
            AppAssets.poiMenu,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            excludeFromSemantics: true,
          ),
        ),
      ),
    ),
  );
}
