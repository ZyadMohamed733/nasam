import '../entities/point_of_interest.dart';

class PickedPoiWorkbook {
  const PickedPoiWorkbook(this.name, this.rows, {this.size = 0});
  final String name;
  final List<List<String>> rows;

  /// The file's size in bytes, when the picker reports it.
  final int size;
}

/// Native workbook selection and export boundary; cancelled dialogs return null/false.
abstract interface class PoiFiles {
  Future<PickedPoiWorkbook?> pick();
  Future<bool> save({List<PointOfInterest>? points});
}
