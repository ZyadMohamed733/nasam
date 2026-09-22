import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/app_config.dart';
import '../../features/tracking/data/dummy_tracking_repository.dart';
import '../../features/tracking/domain/tracking_vehicle.dart';
import 'injection_container.config.dart';

final GetIt getIt = GetIt.instance;

/// Registers the flavor's [AppConfig] before anything that reads it, so
/// `DioClient` and `WebSocketService` cannot be built against an unset
/// configuration.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);
  await getIt.init();
  getIt.registerLazySingleton<TrackingRepository>(DummyTrackingRepository.new);
}
