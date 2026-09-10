import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app_bloc_observer.dart';
import 'app/app_config.dart';
import 'app/app_config_loader.dart';
import 'core/di/injection_container.dart';

/// Shared startup for every flavor entrypoint.
///
/// The order matters: the environment is loaded, the flavor's [AppConfig] is
/// resolved from it, and only then is DI configured — so nothing can be built
/// against configuration that has not been set yet.
Future<void> initSharedLib(Flavor flavor) async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment configurations
  await dotenv.load(fileName: '.env');

  // 3. Resolve this flavor's configuration from the environment
  final config = AppConfigLoader.forFlavor(flavor);

  // 4. Configure GetIt Dependency Injection with that configuration
  await configureDependencies(config);

  // 5. Set global Bloc Observer
  Bloc.observer = AppBlocObserver();
}
