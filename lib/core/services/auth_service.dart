import 'package:injectable/injectable.dart';
import 'secure_storage_service.dart';

abstract class AuthService {
  Future<bool> get isAuthenticated;
  Future<String?> get accessToken;
  Future<void> login(String username, String password);
  Future<void> logout();
}

@LazySingleton(as: AuthService)
class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._secureStorage);
  final SecureStorageService _secureStorage;

  @override
  Future<bool> get isAuthenticated async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> get accessToken => _secureStorage.getAccessToken();

  @override
  Future<void> login(String username, String password) async {
    // Scaffold implementation: mock-saving an access and refresh token.
    // In production, this would make an API call via Dio, mapping to DTO.
    await _secureStorage.saveAccessToken(
      'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await _secureStorage.saveRefreshToken(
      'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }
}
