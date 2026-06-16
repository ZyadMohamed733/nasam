import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() async {

  await initShardLib();
  AppConfig.configure(
    flavor: Flavor.staging,
    appName: AppConstants.stageAppName,
    baseUrl: dotenv.env['STAGE_BASE_URL']!,
    wsUrl: dotenv.env['STAGE_WS_URL']!,
  );
  runApp(const NasamApp());
}