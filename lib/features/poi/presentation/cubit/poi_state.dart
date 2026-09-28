import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/point_of_interest.dart';

enum PoiStatus { initial, loading, loaded, failure }

class PoiState {
  const PoiState({
    this.status = PoiStatus.initial,
    this.points = const [],
    this.query = '',
    this.selectedId,
    this.failure,
  });
  final PoiStatus status;
  final List<PointOfInterest> points;
  final String query;
  final String? selectedId;
  final Failure? failure;
  List<PointOfInterest> get visiblePoints {
    final normalized = foldForSearch(query);
    return points
        .where((point) => foldForSearch(point.name).contains(normalized))
        .toList(growable: false);
  }

  PointOfInterest? get selected {
    for (final point in points) {
      if (point.id == selectedId) return point;
    }
    return null;
  }
}
