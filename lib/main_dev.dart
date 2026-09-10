import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() async {
  await initSharedLib(Flavor.dev);
  runApp(const NasamApp());
}
