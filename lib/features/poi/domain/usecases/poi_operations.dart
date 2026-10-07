import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/poi_draft.dart';
import '../entities/point_of_interest.dart';
import '../repositories/poi_repository.dart';
class GetPointOfInterestUseCase {
  const GetPointOfInterestUseCase(this._repository);
  final PoiRepository _repository;
  Future<Either<Failure, PointOfInterest>> call(String id) =>
      _repository.getPoint(id);
}
class SavePointOfInterestUseCase {
  const SavePointOfInterestUseCase(this._repository);
  final PoiRepository _repository;
  Future<Either<Failure, PointOfInterest>> call(PoiDraft draft, {String? id}) =>
      _repository.save(draft, id: id);
}
class DeletePointOfInterestUseCase {
  const DeletePointOfInterestUseCase(this._repository);
  final PoiRepository _repository;
  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
class ImportPointsOfInterestUseCase {
  const ImportPointsOfInterestUseCase(this._repository);
  final PoiRepository _repository;
  Future<Either<Failure, int>> call(List<PoiDraft> points) =>
      _repository.importPoints(points);
}
class WatchPoiChangesUseCase {
  const WatchPoiChangesUseCase(this._repository);
  final PoiRepository _repository;
  Stream<void> call() => _repository.changes;
}
