import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.dev,
    appName: AppConstants.devAppName,
    baseUrl: dotenv.env['DEV_BASE_URL'] ?? 'https://api-dev.nasam.app',
    wsUrl: dotenv.env['DEV_WS_URL'] ?? 'wss://ws-dev.nasam.app',
  );
  runApp(const NasamApp());
}