import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.prod,
    appName: AppConstants.appName,
    baseUrl: dotenv.env['PROD_BASE_URL'] ?? 'https://api.nasam.app',
    wsUrl: dotenv.env['PROD_WS_URL'] ?? 'wss://ws.nasam.app',
  );
  runApp(const NasamApp());
}