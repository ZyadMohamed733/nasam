import 'package:get_it/get_it.dart';

import '../data/datasources/poi_datasource.dart';
import '../data/datasources/poi_fixture_datasource.dart';
import '../data/repositories/poi_repository_impl.dart';
import '../data/services/poi_file_service.dart';
import '../domain/repositories/poi_files.dart';
import '../domain/repositories/poi_repository.dart';
import '../domain/usecases/get_points_of_interest_usecase.dart';
import '../domain/usecases/poi_operations.dart';
import '../presentation/cubit/poi_cubit.dart';
import '../presentation/cubit/poi_editor_cubit.dart';
import '../presentation/cubit/poi_import_cubit.dart';

void registerPoiDependencies(GetIt getIt) {
  getIt.registerLazySingleton<PoiDataSource>(() => PoiFixtureDataSource());
  getIt.registerLazySingleton<PoiFiles>(() => PoiFileService());
  getIt.registerLazySingleton<PoiRepository>(
    () => PoiRepositoryImpl(getIt<PoiDataSource>()),
    dispose: (poiRepository) => poiRepository.dispose(),
  );
  getIt.registerLazySingleton<GetPointsOfInterestUseCase>(
    () => GetPointsOfInterestUseCase(getIt<PoiRepository>()),
  );
  getIt.registerLazySingleton<GetPointOfInterestUseCase>(
    () => GetPointOfInterestUseCase(getIt<PoiRepository>()),
  );
  getIt.registerLazySingleton<SavePointOfInterestUseCase>(
    () => SavePointOfInterestUseCase(getIt<PoiRepository>()),
  );
  getIt.registerLazySingleton<DeletePointOfInterestUseCase>(
    () => DeletePointOfInterestUseCase(getIt<PoiRepository>()),
  );
  getIt.registerLazySingleton<ImportPointsOfInterestUseCase>(
    () => ImportPointsOfInterestUseCase(getIt<PoiRepository>()),
  );
  getIt.registerLazySingleton<WatchPoiChangesUseCase>(
    () => WatchPoiChangesUseCase(getIt<PoiRepository>()),
  );
  getIt.registerFactory<PoiImportCubit>(
    () => PoiImportCubit(
      getIt<PoiFiles>(),
      getIt<GetPointsOfInterestUseCase>(),
      getIt<ImportPointsOfInterestUseCase>(),
    ),
  );
  getIt.registerFactory<PoiEditorCubit>(
    () => PoiEditorCubit(
      getIt<GetPointOfInterestUseCase>(),
      getIt<SavePointOfInterestUseCase>(),
      getIt<DeletePointOfInterestUseCase>(),
    ),
  );
  getIt.registerFactory<PoiCubit>(
    () => PoiCubit(
      getIt<GetPointsOfInterestUseCase>(),
      getIt<PoiFiles>(),
      getIt<DeletePointOfInterestUseCase>(),
      getIt<WatchPoiChangesUseCase>(),
    ),
  );
}
