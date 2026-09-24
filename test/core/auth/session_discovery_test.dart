import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
import 'package:nasam/core/auth/token_refresher.dart';
import 'package:nasam/core/constants/app_strings.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/router/route_guard.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/core/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_helper.dart';
import '../../helpers/recording_adapter.dart';

class _FakeGoRouterState extends Fake implements GoRouterState {
  _FakeGoRouterState(String location) : uri = Uri.parse(location);

  @override
  final Uri uri;

  @override
  String get matchedLocation => uri.path;
}

class _FakeBuildContext extends Fake implements BuildContext {}

/// The keychain could not be read at startup — locked, say, before the first
/// unlock — so the app began believing it was signed out. It was not, and
/// when that session later expires the user must be told and brought back,
/// not silently dropped at a login screen.
void main() {
  test(
    'a token found after a failed startup read still expires properly',
    () async {
      final keychain = MockFlutterSecureStorage();
      var reads = 0;
      when(() => keychain.read(key: AppStrings.keyAccessToken)).thenAnswer((
        _,
      ) async {
        if (reads++ == 0) throw StateError('keychain locked');
        return 'live-access';
      });
      when(
        () => keychain.read(key: AppStrings.keyRefreshToken),
      ).thenAnswer((_) async => 'refresh-1');
      when(
        () => keychain.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
      SharedPreferences.setMockInitialValues({
        AppStrings.keyAuthStorageInitialised: true,
      });

      final storage = await SecureStorageService.open(
        keychain,
        await SharedPreferences.getInstance(),
      );
      final session = AuthSessionNotifier(storage);
      expect(session.value, AuthSessionStatus.signedOut, reason: 'startup');

      var notified = 0;
      session.addListener(() => notified++);

      // The first request's token lookup succeeds this time.
      expect(await storage.getAccessToken(), 'live-access');
      expect(session.value, AuthSessionStatus.signedIn);
      expect(await storage.getAccessToken(), 'live-access');
      expect(notified, 1, reason: 'no repeat notice for the same state');

      // Then the server rejects the refresh.
      final client = Dio()
        ..httpClientAdapter = RecordingAdapter((_) => (401, null));
      final refresher = TokenRefresher(
        storage,
        session,
        client,
        MockErrorReporter(),
      );
      expect(await refresher.refresh(), isNull);
      expect(session.value, AuthSessionStatus.expired);

      // And the guard sends them to login holding their place.
      final guard = RouteGuard(AuthServiceImpl(storage), session);
      final redirect = await guard.handleRedirect(
        _FakeBuildContext(),
        _FakeGoRouterState('/assets/AST-1'),
      );
      final uri = Uri.parse(redirect!);
      expect(uri.path, AppRoutes.login);
      expect(uri.queryParameters[AppRoutes.returnToParam], '/assets/AST-1');
    },
  );
}
