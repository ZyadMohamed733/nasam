import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/error_reporter.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/core/services/secure_storage_service.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDio extends Mock implements Dio {}

class MockErrorReporter extends Mock implements ErrorReporter {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockWebSocketService extends Mock implements WebSocketService {}

class MockAuthService extends Mock implements AuthService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockStorageService extends Mock implements StorageService {}
