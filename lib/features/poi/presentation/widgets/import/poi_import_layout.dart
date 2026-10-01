import '../../../../../shared/widgets/app_data_table.dart';

/// The bulk upload's geometry, from Upload (`647:7950`), Validation
/// (`647:7969`), Preview (`647:7988`) and Confirm (`647:8007`) in
/// `design_exports/nasam_mobile_2/poi_nodes.json`.
abstract final class PoiImportLayout {
  static const double gutter = 16;
  static const double maxWidth = 600;

  /// From the header's bottom to the stepper (`561:17018` sits 17.5 below
  /// the header with 4 of its own padding).
  static const double contentTop = 22;
  static const double stepperGap = 16;

  // Upload (561:12170).
  static const double cardBorder = 1;
  static const double bandPadding = 16;
  static const double infoRowHeight = 20;
  static const double infoGap = 5;
  static const double templateWidth = 131;
  static const double templateHeight = 40;
  static const double templateIcon = 16;

  /// The drop area is a fixed 274 with the drop zone centred in it.
  static const double dropAreaHeight = 274;
  static const double dropAreaPadding = 16;
  static const double fileRowGap = 12;
  static const double fileRowPadding = 12;
  static const double fileIcon = 24;
  static const double fileIconGap = 8;

  // Validation and Preview (561:13774, 561:15177).
  static const double titleGap = 8;
  static const double chipRowPadding = 12;
  static const double chipGap = 4;
  static const double previewTableGap = 8;

  /// Validation's columns, from the start: name, latitude, longitude,
  /// icon, status, reason (`561:13807`).
  static const List<double> validationColumns = [131, 74, 81, 95, 97, 197];

  /// Preview's columns, from the start: name, latitude, longitude, icon,
  /// status — 370 in all (`561:15641`).
  static const List<double> previewColumns = [113, 64.25, 64.25, 64.25, 64.25];

  // Confirm (561:16904).
  static const double cardPaddingH = 16;
  static const double cardPaddingV = 24;
  static const double cardGap = 24;
  static const double cardTextGap = 8;
  static const double iconTile = 64;
  static const double iconTileGlyph = 24;
  static const double tileGap = 8;

  /// The link's frame (`561:16939`) is 16 tall, 16 under the card, with
  /// its 44 button overflowing it centred: so the button starts 2 below.
  static const double linkGap = 2;
  static const double linkInset = 24;

  /// Columns with their design widths, labels in column order.
  static List<AppDataColumn> columns(
    List<String> labels,
    List<double> widths, {
    int? sortable,
  }) => [
    for (var i = 0; i < labels.length; i++)
      AppDataColumn(
        label: labels[i],
        width: widths[i],
        sortable: i == sortable,
      ),
  ];
}
