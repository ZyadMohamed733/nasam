import '../entities/point_of_interest.dart';

class PickedPoiWorkbook {
  const PickedPoiWorkbook(this.name, this.rows);
  final String name;
  final List<List<String>> rows;
}

/// Native workbook selection and export boundary; cancelled dialogs return null/false.
abstract interface class PoiFiles {
  Future<PickedPoiWorkbook?> pick();
  Future<bool> save({List<PointOfInterest>? points});
}
