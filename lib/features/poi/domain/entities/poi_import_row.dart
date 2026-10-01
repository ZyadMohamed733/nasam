import 'poi_draft.dart';
import 'poi_validation.dart';
import 'point_of_interest.dart';

enum PoiRowStatus { valid, invalid, duplicate }

class PoiImportRow {
  const PoiImportRow({
    required this.number,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.iconName,
    required this.status,
    this.issues = const [],
    this.draft,
  });
  final int number;
  final String name, latitude, longitude, iconName;
  final PoiRowStatus status;

  /// Why an invalid row will not be imported, in field order.
  final List<PoiIssue> issues;
  final PoiDraft? draft;
}

abstract final class PoiImportValidation {
  static String identity(String name, double lat, double lon) =>
      '${name.trim().toLowerCase()}|$lat|$lon';
  static List<PoiImportRow> validate(
    List<List<String>> rows,
    List<PointOfInterest> existing,
  ) {
    const aliases = {
      'اسم نقطة الاهتمام': 'name',
      'خط العرض': 'latitude',
      'خط الطول': 'longitude',
      'الأيقونة': 'icon',
      'الايقون': 'icon',
      'الملاحظات': 'notes',
    };
    final headers = rows.first
        .map((v) => aliases[v.trim()] ?? v.trim().toLowerCase())
        .toList();
    if (headers.toSet().length != headers.length ||
        !['name', 'latitude', 'longitude', 'icon'].every(headers.contains)) {
      throw const FormatException('Use the POI template columns');
    }
    final known = existing
        .map((p) => identity(p.name, p.latitude, p.longitude))
        .toSet();
    return [
      for (var i = 1; i < rows.length; i++)
        _row(i + 1, rows[i], headers, known),
    ];
  }

  static PoiImportRow _row(
    int number,
    List<String> cells,
    List<String> headers,
    Set<String> known,
  ) {
    String value(String name) {
      final index = headers.indexOf(name);
      return index < 0 || index >= cells.length ? '' : cells[index].trim();
    }

    final name = value('name');
    final issues = PoiValidator.all(
      name: name,
      latitude: value('latitude'),
      longitude: value('longitude'),
      icon: value('icon'),
      notes: value('notes'),
    );
    final draft = issues.isNotEmpty
        ? null
        : PoiDraft(
            name: name,
            latitude: double.parse(value('latitude')),
            longitude: double.parse(value('longitude')),
            icon: PoiValidator.icon(value('icon'))!,
            notes: value('notes'),
          );
    final status = draft == null
        ? PoiRowStatus.invalid
        : known.add(identity(name, draft.latitude, draft.longitude))
        ? PoiRowStatus.valid
        : PoiRowStatus.duplicate;
    return PoiImportRow(
      number: number,
      name: name,
      latitude: value('latitude'),
      longitude: value('longitude'),
      iconName: value('icon').toLowerCase(),
      status: status,
      issues: List.unmodifiable(issues),
      draft: draft,
    );
  }
}
