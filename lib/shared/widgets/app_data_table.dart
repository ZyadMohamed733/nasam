import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_component_colors.dart';
import '../../core/theme/app_status_tones.dart';
import '../../core/theme/app_text_styles.dart';

/// A column of an [AppDataTable]: its header and its design width.
class AppDataColumn {
  const AppDataColumn({
    required this.label,
    required this.width,
    this.sortable = false,
  });

  final String label;
  final double width;

  /// Shows the design's sort glyph after the label. Decorative: the table
  /// does not sort.
  final bool sortable;
}

/// A row of an [AppDataTable]: one cell per column, in column order.
class AppDataRow {
  const AppDataRow({required this.cells, this.flagged = false});

  final List<Widget> cells;

  /// Outlines the row in the danger tone's tint, as the design marks a row
  /// that will not be imported (`561:13841`).
  final bool flagged;
}

/// The design's data table (`561:13807`): a 36-tall header on the table
/// fill, then 48-tall rows, every cell 12 in from its sides with 1px
/// borders; top corners rounded 8.
///
/// Columns keep their design widths; when they add up to less than the
/// space, they share the rest in proportion, and when they add up to more,
/// the table scrolls sideways — from the start, so the first column shows.
class AppDataTable extends StatelessWidget {
  const AppDataTable({super.key, required this.columns, required this.rows});

  final List<AppDataColumn> columns;
  final List<AppDataRow> rows;

  static const double headerHeight = 36;
  static const double rowHeight = 48;
  static const double cellPadding = 12;
  static const double sortIcon = 12;
  static const double sortGap = 4;

  /// A cell's plain value: 12 on a 20 line.
  static Widget text(BuildContext context, String value) => Text(
    value,
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyles.bodySR20.copyWith(
      color: context.semanticColors.textColor,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = AppComponentColors.of(context);
    final flag = AppStatusTones.of(context).danger.background;
    final designWidth = columns.fold<double>(0, (sum, c) => sum + c.width);
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = designWidth < constraints.maxWidth
            ? constraints.maxWidth / designWidth
            : 1.0;
        final widths = [for (final c in columns) c.width * scale];
        Widget cell(int i, Widget child, {Color? border, Color? fill}) =>
            Container(
              width: widths[i],
              constraints: BoxConstraints(
                minHeight: fill == null ? rowHeight : headerHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: cellPadding),
              alignment: AlignmentDirectional.centerStart,
              decoration: BoxDecoration(
                color: fill,
                border: Border.all(color: border ?? colors.tableBorder),
              ),
              child: child,
            );
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.r8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < columns.length; i++)
                      cell(
                        i,
                        _Header(column: columns[i]),
                        fill: colors.tableHeaderFill,
                      ),
                  ],
                ),
                for (final row in rows)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < columns.length; i++)
                          cell(
                            i,
                            row.cells[i],
                            border: row.flagged ? flag : null,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.column});

  final AppDataColumn column;

  @override
  Widget build(BuildContext context) {
    final color = context.semanticColors.textPlaceholder;
    return Semantics(
      header: true,
      child: Row(
        children: [
          Flexible(
            child: Text(
              column.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionSB.copyWith(color: color),
            ),
          ),
          if (column.sortable) ...[
            const SizedBox(width: AppDataTable.sortGap),
            ExcludeSemantics(
              child: Icon(
                Icons.swap_vert,
                size: AppDataTable.sortIcon,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
