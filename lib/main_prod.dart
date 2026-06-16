import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() async {



  await initShardLib();
  AppConfig.configure(
    flavor: Flavor.prod,
    appName: AppConstants.appName,
    baseUrl: dotenv.env['PROD_BASE_URL']!,
    wsUrl: dotenv.env['PROD_WS_URL']!,
  );
  runApp(const NasamApp());
}