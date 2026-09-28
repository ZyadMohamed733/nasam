import '../models/poi_model.dart';

abstract interface class PoiDataSource {
  Future<List<PoiModel>> getPoints();
  Future<PoiModel> save(PoiModel point, {required bool create});
  Future<void> delete(String id);
  Future<int> importPoints(List<PoiModel> points);
}
