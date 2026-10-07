import 'package:get_it/get_it.dart';

import '../../app/app_config.dart';
import '../../features/auth/di/auth_dependencies.dart';
import '../../features/history_alert/di/history_alert_dependencies.dart';
import '../../features/onboarding/di/onboarding_dependencies.dart';
import '../../features/play_back/di/play_back_dependencies.dart';
import '../../features/poi/di/poi_dependencies.dart';
import '../../features/tracking/di/tracking_dependencies.dart';
import 'app_dependencies.dart';
import 'network_dependencies.dart';
import 'session_dependencies.dart';
import 'storage_dependencies.dart';

final GetIt getIt = GetIt.instance;

/// Register the app configuration before dependencies that read it.
Future<void> configureDependencies(AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);

  await registerStorageDependencies(getIt);
  registerNetworkDependencies(getIt);
  registerSessionDependencies(getIt);
  registerAppDependencies(getIt);
  registerAuthDependencies(getIt);
  registerHistoryAlertDependencies(getIt);
  registerOnboardingDependencies(getIt);
  registerPlayBackDependencies(getIt);
  registerPoiDependencies(getIt);
  registerTrackingDependencies(getIt);
}
