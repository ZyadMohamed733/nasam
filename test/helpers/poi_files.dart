import 'package:nasam/features/poi/domain/entities/point_of_interest.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';

class FakePoiFiles implements PoiFiles {
  PickedPoiWorkbook? selected;
  bool fail = false;
  List<PointOfInterest>? exported;
  @override
  Future<PickedPoiWorkbook?> pick() async {
    if (fail) throw const FormatException('Invalid file');
    return selected;
  }

  @override
  Future<bool> save({List<PointOfInterest>? points}) async {
    exported = points;
    return true;
  }
}
