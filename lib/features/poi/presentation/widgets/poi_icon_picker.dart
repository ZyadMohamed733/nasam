import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/poi_sheet_colors.dart';
import '../../../../shared/widgets/map_sheet_header.dart';
import '../../domain/entities/poi_draft.dart';
import 'poi_icon.dart';

/// Opens the icon picker (`647:8257`) and returns the chosen icon, or null if
/// it was dismissed.
Future<PoiIcon?> showPoiIconPicker(BuildContext context, {PoiIcon? selected}) =>
    showModalBottomSheet<PoiIcon>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PoiIconPicker.radius),
        ),
      ),
      builder: (context) => PoiIconPicker(
        selected: selected,
        onSelected: (icon) => Navigator.of(context).pop(icon),
      ),
    );

/// The picker's content: the sheet handle, the "icon" heading, then one row
/// per [PoiIcon] — its 24 glyph and name.
///
/// The design's rows are 43.75 apart; these are 48, the touch minimum. The
/// design has no selected row, so the current icon takes the list's
/// provisional selected fill (see docs/backlog.md).
class PoiIconPicker extends StatelessWidget {
  const PoiIconPicker({super.key, required this.onSelected, this.selected});

  final PoiIcon? selected;
  final ValueChanged<PoiIcon> onSelected;

  static const double radius = 32;
  static const double gutter = 16;
  static const double headingHeight = 32;
  static const double headingInset = 16;
  static const double rowHeight = kMinInteractiveDimension;
  static const double rowInset = 8;
  static const double icon = 24;
  static const double iconGap = 12;

  static ValueKey<String> rowKey(PoiIcon icon) =>
      ValueKey('poi-icon-picker-${icon.name}');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final colors = PoiSheetColors.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MapSheetHandle(color: colors.handle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: headingHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: headingInset,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Semantics(
                        header: true,
                        child: Text(
                          l.poiIcon,
                          style: AppTextStyles.bodySR.copyWith(
                            color: s.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final icon in PoiIcon.values)
                  _Row(
                    key: rowKey(icon),
                    icon: icon,
                    selected: icon == selected,
                    fill: colors.rowSelectedFill,
                    onTap: () => onSelected(icon),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.icon,
    required this.selected,
    required this.fill,
    required this.onTap,
  });

  final PoiIcon icon;
  final bool selected;
  final Color fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = context.semanticColors;
    final radius = BorderRadius.circular(AppSizes.r8);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? fill : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: PoiIconPicker.rowHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: PoiIconPicker.rowInset,
              ),
              child: Row(
                children: [
                  PoiIconImage(
                    icon: icon,
                    size: PoiIconPicker.icon,
                    color: s.iconPrimaryBlack,
                  ),
                  const SizedBox(width: PoiIconPicker.iconGap),
                  Text(
                    PoiIconStyle.label(icon, l),
                    style: AppTextStyles.bodyMR.copyWith(color: s.textColor),
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
