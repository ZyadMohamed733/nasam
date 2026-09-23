import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tracking_vehicle.dart';
import '../repositories/tracking_repository.dart';

@lazySingleton
class GetTrackingVehiclesUseCase {
  const GetTrackingVehiclesUseCase(this._repository);
  final TrackingRepository _repository;

  Future<Either<Failure, List<TrackingVehicle>>> call() =>
      _repository.getVehicles();
}
