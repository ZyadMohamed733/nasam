import 'poi_draft.dart';
import 'poi_limits.dart';

/// Why a point of interest's field is not acceptable.
enum PoiIssue {
  nameRequired,
  nameTooLong,
  latitudeInvalid,
  longitudeInvalid,
  iconUnknown,
  notesTooLong,
}

/// The field rules a point of interest must meet — the same for the form
/// and for every row of a bulk upload.
abstract final class PoiValidator {
  static PoiIssue? name(String value) {
    final name = value.trim();
    if (name.isEmpty) return PoiIssue.nameRequired;
    if (name.length > PoiLimits.maxNameLength) return PoiIssue.nameTooLong;
    return null;
  }

  static PoiIssue? latitude(String value) =>
      _coordinate(value, PoiLimits.maxLatitude)
      ? null
      : PoiIssue.latitudeInvalid;

  static PoiIssue? longitude(String value) =>
      _coordinate(value, PoiLimits.maxLongitude)
      ? null
      : PoiIssue.longitudeInvalid;

  static PoiIssue? notes(String value) =>
      value.length > PoiLimits.maxNotesLength ? PoiIssue.notesTooLong : null;

  /// The icon a workbook names, or null if it names none we know.
  static PoiIcon? icon(String value) {
    final name = value.trim().toLowerCase();
    return PoiIcon.values.where((i) => i.name == name).firstOrNull;
  }

  /// Every issue with a set of raw field values, in field order.
  static List<PoiIssue> all({
    required String name,
    required String latitude,
    required String longitude,
    required String icon,
    required String notes,
  }) => [
    ?PoiValidator.name(name),
    ?PoiValidator.latitude(latitude),
    ?PoiValidator.longitude(longitude),
    if (PoiValidator.icon(icon) == null) PoiIssue.iconUnknown,
    ?PoiValidator.notes(notes),
  ];

  static bool _coordinate(String value, double max) {
    final n = double.tryParse(value.trim());
    return n != null && n.isFinite && n.abs() <= max;
  }
}
