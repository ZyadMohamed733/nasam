import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nasam/app/app.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/features/auth/presentation/pages/login_page.dart';
import 'package:nasam/features/home/presentation/pages/home_page.dart';

/// Drives the real widget tree through splash -> login -> home.
///
/// Run on a device or emulator:
///   flutter test integration_test/app_test.dart --flavor dev \
///     --dart-define-from-file=config/dev.json
///
/// The AppConfig is registered directly rather than resolved from
/// `AppConfigLoader`, so the test does not depend on which dart-defines the
/// runner was given.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig(
    flavor: Flavor.dev,
    appName: 'Nasam Dev',
    baseUrl: 'https://api-dev.nasam.app/v1',
    wsUrl: 'wss://ws-dev.nasam.app',
  );

  setUp(() async {
    await getIt.reset();
    await configureDependencies(config);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('an unauthenticated launch lands on login', (tester) async {
    await tester.pumpWidget(const NasamApp());

    // Splash holds for two seconds before handing over to the router.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('the route guard keeps home unreachable while signed out', (
    tester,
  ) async {
    await tester.pumpWidget(const NasamApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    final router = getIt<AppRouter>().config;
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
