import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/geofence.dart';
import '../entities/geofence_draft.dart';
import '../repositories/geofence_repository.dart';
class GetGeofencesUseCase { const GetGeofencesUseCase(this.r); final GeofenceRepository r; Future<Either<Failure,List<Geofence>>> call()=>r.getGeofences(); }
class GetGeofenceUseCase { const GetGeofenceUseCase(this.r); final GeofenceRepository r; Future<Either<Failure,Geofence>> call(String id)=>r.getGeofence(id); }
class SaveGeofenceUseCase { const SaveGeofenceUseCase(this.r); final GeofenceRepository r; Future<Either<Failure,Geofence>> call(GeofenceDraft d,{String? id})=>r.save(d,id:id); }
class DeleteGeofenceUseCase { const DeleteGeofenceUseCase(this.r); final GeofenceRepository r; Future<Either<Failure,Unit>> call(String id)=>r.delete(id); }
class GetGeofenceAssetOptionsUseCase { const GetGeofenceAssetOptionsUseCase(this.r); final GeofenceRepository r; Future<Either<Failure,List<GeofenceAssetOption>>> call()=>r.getAssetOptions(); }
class WatchGeofenceChangesUseCase { const WatchGeofenceChangesUseCase(this.r); final GeofenceRepository r; Stream<void> call()=>r.changes; }
