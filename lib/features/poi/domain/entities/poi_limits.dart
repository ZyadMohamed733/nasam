/// The limits a point of interest and a bulk upload must respect, in one
/// place for the form, the import, the workbook reader and the screens that
/// state them.
abstract final class PoiLimits {
  /// The only workbook format accepted, as the upload screen shows it.
  static const String fileExtension = '.xlsx';

  /// The largest workbook, in megabytes, as the upload screen shows it.
  static const int maxFileMegabytes = 20;
  static const int maxFileBytes = maxFileMegabytes * 1024 * 1024;

  /// The most records one upload may hold.
  static const int maxRecords = 5000;

  static const int maxNameLength = 200;
  static const int maxNotesLength = 2000;
  static const double maxLatitude = 90;
  static const double maxLongitude = 180;
}
