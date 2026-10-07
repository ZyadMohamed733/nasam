import 'package:get_it/get_it.dart';

import '../data/datasources/playback_datasource.dart';
import '../data/datasources/playback_fixture_datasource.dart';
import '../data/repositories/playback_repository_impl.dart';
import '../domain/repositories/playback_repository.dart';
import '../domain/usecases/get_playback_route_usecase.dart';
import '../domain/usecases/get_playback_segments_usecase.dart';
import '../presentation/cubit/playback_cubit.dart';
import '../presentation/cubit/playback_map_cubit.dart';

void registerPlayBackDependencies(GetIt getIt) {
  getIt.registerLazySingleton<PlaybackDataSource>(
    () => PlaybackFixtureDataSource(),
  );
  getIt.registerLazySingleton<PlaybackRepository>(
    () => PlaybackRepositoryImpl(getIt<PlaybackDataSource>()),
  );
  getIt.registerLazySingleton<GetPlaybackRouteUseCase>(
    () => GetPlaybackRouteUseCase(getIt<PlaybackRepository>()),
  );
  getIt.registerLazySingleton<GetPlaybackSegmentsUseCase>(
    () => GetPlaybackSegmentsUseCase(getIt<PlaybackRepository>()),
  );
  getIt.registerFactory<PlaybackCubit>(
    () => PlaybackCubit(getIt<GetPlaybackSegmentsUseCase>()),
  );
  getIt.registerFactory<PlaybackMapCubit>(
    () => PlaybackMapCubit(getIt<GetPlaybackRouteUseCase>()),
  );
}
