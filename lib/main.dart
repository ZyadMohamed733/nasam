import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/di/injection_container.dart';

void main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment configurations
  await dotenv.load(fileName: '.env');

  // 3. Configure GetIt Dependency Injection
  await configureDependencies();

  // 4. Set global Bloc Observer
  Bloc.observer = AppBlocObserver();

  // 5. Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 6. Bootstrap the application
  runApp(const NasamApp());
}
