import 'package:get_it/get_it.dart';
import '../data/datasources/geofence_datasource.dart';
import '../data/datasources/geofence_fixture_datasource.dart';
import '../data/repositories/geofence_repository_impl.dart';
import '../domain/repositories/geofence_repository.dart';
import '../domain/usecases/geofence_operations.dart';
import '../presentation/cubit/geofence_cubit.dart';
import '../presentation/cubit/geofence_editor_cubit.dart';
import '../presentation/cubit/geofence_map_cubit.dart';
void registerGeofenceDependencies(GetIt getIt) {
  getIt.registerLazySingleton<GeofenceDataSource>(()=>GeofenceFixtureDataSource());
  getIt.registerLazySingleton<GeofenceRepository>(()=>GeofenceRepositoryImpl(getIt()),dispose:(r)=>r.dispose());
  getIt.registerLazySingleton(()=>GetGeofencesUseCase(getIt()));
  getIt.registerLazySingleton(()=>GetGeofenceUseCase(getIt()));
  getIt.registerLazySingleton(()=>SaveGeofenceUseCase(getIt()));
  getIt.registerLazySingleton(()=>DeleteGeofenceUseCase(getIt()));
  getIt.registerLazySingleton(()=>GetGeofenceAssetOptionsUseCase(getIt()));
  getIt.registerLazySingleton(()=>WatchGeofenceChangesUseCase(getIt()));
  getIt.registerFactory(()=>GeofenceCubit(getIt(),getIt(),getIt()));
  getIt.registerFactory(()=>GeofenceEditorCubit(getIt(),getIt()));
  getIt.registerFactory(()=>GeofenceMapCubit());
}
