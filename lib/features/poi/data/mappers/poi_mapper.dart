import '../../domain/entities/poi_draft.dart';
import '../../domain/entities/point_of_interest.dart';
import '../models/poi_model.dart';

abstract final class PoiMapper {
  static PointOfInterest point(PoiModel model) => PointOfInterest(
    id: model.id,
    name: model.name,
    latitude: model.latitude,
    longitude: model.longitude,
    icon: PoiIcon.values.firstWhere((v) => v.name == model.icon),
    notes: model.notes,
  );
}
