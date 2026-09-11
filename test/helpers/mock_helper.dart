import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/core/services/secure_storage_service.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/features/_template/data/datasources/local/template_local_datasource.dart';
import 'package:nasam/features/_template/data/datasources/remote/template_remote_datasource.dart';
import 'package:nasam/features/_template/domain/repositories/template_repository.dart';
import 'package:nasam/features/_template/domain/usecases/get_template_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDio extends Mock implements Dio {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockGetTemplateUseCase extends Mock implements GetTemplateUseCase {}

class MockTemplateRemoteDataSource extends Mock
    implements TemplateRemoteDataSource {}

class MockTemplateLocalDataSource extends Mock
    implements TemplateLocalDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockWebSocketService extends Mock implements WebSocketService {}

class MockAuthService extends Mock implements AuthService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockStorageService extends Mock implements StorageService {}
