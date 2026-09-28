import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/poi_draft.dart';
import '../entities/point_of_interest.dart';

abstract interface class PoiRepository {
  Stream<void> get changes;
  Future<void> dispose();
  Future<Either<Failure, List<PointOfInterest>>> getPoints();
  Future<Either<Failure, PointOfInterest>> getPoint(String id);
  Future<Either<Failure, PointOfInterest>> save(PoiDraft draft, {String? id});
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, int>> importPoints(List<PoiDraft> drafts);
}
