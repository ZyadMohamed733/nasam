import 'package:injectable/injectable.dart';

import 'secure_storage_service.dart';

/// A read-only view of the current session for code that only needs to ask
/// "is someone signed in" -- `RouteGuard`, the shared app chrome.
///
/// This is deliberately not where sign-in/out happens: those are credential
/// exchanges with side effects (persisting or clearing tokens and the user
/// profile) and belong to `AuthRepositoryImpl`, in `features/auth/data/`,
/// which is the only place that should write these keys. Core services stay
/// feature-agnostic, so this cannot depend on the auth feature's usecases --
/// callers that need to act (sign in, sign out) use
/// `features/auth/domain/usecases/` directly.
abstract class AuthService {
  Future<bool> get isAuthenticated;
  Future<String?> get accessToken;

  /// The signed-in user's profile, as raw JSON (whatever
  /// `AuthRepositoryImpl` last persisted via `SecureStorageService.saveUser`).
  /// Kept as a string rather than a typed entity: parsing it into a domain
  /// `UserEntity` needs the auth feature's mapper, which this feature-agnostic
  /// service must not import. A caller that wants the typed user reads this
  /// feature's own state instead (e.g. via its cubit).
  Future<String?> get currentUser;
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
  Future<String?> get currentUser => _secureStorage.getUser();
}
