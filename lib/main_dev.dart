import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nasam/main.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {


  await initShardLib();
  AppConfig.configure(
    flavor: Flavor.dev,
    appName: AppConstants.devAppName,
    baseUrl: dotenv.env['DEV_BASE_URL']!,
    wsUrl: dotenv.env['DEV_WS_URL']!,
  );
  runApp(const NasamApp());
}