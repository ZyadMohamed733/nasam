import 'package:get_it/get_it.dart';

import '../data/datasources/tracking_datasource.dart';
import '../data/datasources/tracking_fixture_datasource.dart';
import '../data/repositories/tracking_repository_impl.dart';
import '../domain/repositories/tracking_repository.dart';
import '../domain/usecases/get_asset_details_usecase.dart';
import '../domain/usecases/get_asset_notifications_usecase.dart';
import '../domain/usecases/get_tracked_asset_usecase.dart';
import '../domain/usecases/get_tracked_assets_usecase.dart';
import '../domain/usecases/get_tracking_vehicles_usecase.dart';
import '../presentation/cubit/asset_details_cubit.dart';
import '../presentation/cubit/tracked_asset_cubit.dart';
import '../presentation/cubit/tracking_cubit.dart';

void registerTrackingDependencies(GetIt getIt) {
  getIt.registerLazySingleton<TrackingDataSource>(
    () => TrackingFixtureDataSource(),
  );
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(getIt<TrackingDataSource>()),
  );
  getIt.registerLazySingleton<GetAssetDetailsUseCase>(
    () => GetAssetDetailsUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton<GetAssetNotificationsUseCase>(
    () => GetAssetNotificationsUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton<GetTrackedAssetUseCase>(
    () => GetTrackedAssetUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton<GetTrackedAssetsUseCase>(
    () => GetTrackedAssetsUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton<GetTrackingVehiclesUseCase>(
    () => GetTrackingVehiclesUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerFactory<TrackingCubit>(
    () => TrackingCubit(
      getIt<GetTrackingVehiclesUseCase>(),
      getIt<GetTrackedAssetsUseCase>(),
    ),
  );
  getIt.registerFactory<TrackedAssetCubit>(
    () => TrackedAssetCubit(getIt<GetTrackedAssetUseCase>()),
  );
  getIt.registerFactory<AssetDetailsCubit>(
    () => AssetDetailsCubit(
      getIt<GetAssetDetailsUseCase>(),
      getIt<GetAssetNotificationsUseCase>(),
    ),
  );
}
