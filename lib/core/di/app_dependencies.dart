import 'package:get_it/get_it.dart';

import '../../app/app_config.dart';
import '../../app/app_settings_controller.dart';
import '../auth/auth_session_notifier.dart';
import '../errors/error_reporter.dart';
import '../router/app_router.dart';
import '../router/route_guard.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';

void registerAppDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ErrorReporter>(() => ErrorReporter());
  getIt.registerLazySingleton<AppSettingsController>(
    () => AppSettingsController(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<WebSocketService>(
    () => WebSocketService(getIt<AppConfig>()),
    dispose: (webSocketService) => webSocketService.dispose(),
  );
  getIt.registerFactory<RouteGuard>(
    () => RouteGuard(getIt<AuthService>(), getIt<AuthSessionNotifier>()),
  );
  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt<RouteGuard>(), getIt<AuthSessionNotifier>()),
  );
}
