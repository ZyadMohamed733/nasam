import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/app_config.dart';
import 'injection_container.config.dart';

final GetIt getIt = GetIt.instance;

/// Registers the flavor's [AppConfig] before anything that reads it, so
/// `DioClient` and `WebSocketService` cannot be built against an unset
/// configuration.
///
/// The flavor name is also the injectable environment. Without it every
/// `@Environment`-scoped binding is silently skipped, which is how a dev-only
/// dummy data source would end up either registered everywhere or nowhere.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);
  await getIt.init(environment: config.flavor.name);
}
