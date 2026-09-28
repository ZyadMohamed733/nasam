import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/point_of_interest.dart';
import '../repositories/poi_repository.dart';

@lazySingleton
class GetPointsOfInterestUseCase {
  const GetPointsOfInterestUseCase(this._repository);
  final PoiRepository _repository;
  Future<Either<Failure, List<PointOfInterest>>> call() =>
      _repository.getPoints();
}
