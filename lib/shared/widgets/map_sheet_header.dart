import 'package:flutter/material.dart';

/// The drag handle at the top of a map sheet: a fully rounded bar, centred,
/// [barTop] down a [height]-tall strip.
///
/// Decorative: the whole sheet drags, and the header's toggle is the
/// accessible way to open and close it. Defaults are the design's
/// "Drawer handle" (`175:4141`).
class MapSheetHandle extends StatelessWidget {
  const MapSheetHandle({
    super.key,
    required this.color,
    this.height = 34,
    this.barTop = 12,
    this.barSize = const Size(56, 3),
  });

  final Color color;
  final double height;
  final double barTop;
  final Size barSize;

  static const barKey = ValueKey('map-sheet-handle-bar');

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: barTop),
        child: Container(
          key: barKey,
          width: barSize.width,
          height: barSize.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(barSize.height),
          ),
        ),
      ),
    ),
  );
}

/// A map sheet's handle, then its title with the open/close action at the
/// end. Shared by the tracking and POI sheets.
class MapSheetHeader extends StatelessWidget {
  const MapSheetHeader({
    super.key,
    required this.handle,
    required this.title,
    required this.action,
    this.titleStyle,
    this.padding = EdgeInsets.zero,
    this.minRowHeight = 0,
  });

  final MapSheetHandle handle;
  final String title;
  final TextStyle? titleStyle;

  /// At the row's end: the sheet's show/close toggle.
  final Widget action;

  /// Around the title row.
  final EdgeInsetsGeometry padding;

  /// The row's height at the design's text scale. Larger text grows it.
  final double minRowHeight;

  static const titleRowKey = ValueKey('map-sheet-title-row');

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      handle,
      Padding(
        padding: padding,
        child: ConstrainedBox(
          key: titleRowKey,
          constraints: BoxConstraints(minHeight: minRowHeight),
          child: Row(
            children: [
              Expanded(child: Text(title, style: titleStyle)),
              action,
            ],
          ),
        ),
      ),
    ],
  );
}
