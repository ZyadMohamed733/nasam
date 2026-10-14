import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/geofence.dart';
import '../entities/geofence_draft.dart';
abstract interface class GeofenceRepository {
  Stream<void> get changes;
  Future<void> dispose();
  Future<Either<Failure, List<Geofence>>> getGeofences();
  Future<Either<Failure, Geofence>> getGeofence(String id);
  Future<Either<Failure, Geofence>> save(GeofenceDraft draft, {String? id});
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, List<GeofenceAssetOption>>> getAssetOptions();
}
