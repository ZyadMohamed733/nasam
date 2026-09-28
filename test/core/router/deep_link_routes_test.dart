import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/core/router/app_router.dart';
import 'package:nasam/core/router/app_routes.dart';
import 'package:nasam/core/services/auth_service.dart';
import 'package:nasam/features/auth/domain/entities/auth_session_entity.dart';
import 'package:nasam/features/auth/domain/entities/login_result.dart';
import 'package:nasam/features/auth/domain/usecases/login_usecase.dart';
import 'package:nasam/features/auth/presentation/pages/login_page.dart';
import 'package:nasam/features/home/presentation/pages/home_page.dart';
import 'package:nasam/features/play_back/data/datasources/playback_datasource.dart';
import 'package:nasam/features/play_back/data/datasources/playback_fixture_datasource.dart';
import 'package:nasam/features/play_back/presentation/pages/playback_page.dart';
import 'package:nasam/features/play_back/presentation/utils/playback_range.dart';
import 'package:nasam/features/poi/data/datasources/poi_datasource.dart';
import 'package:nasam/features/poi/data/datasources/poi_fixture_datasource.dart';
import 'package:nasam/features/poi/domain/repositories/poi_files.dart';
import 'package:nasam/features/poi/domain/repositories/poi_repository.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_details_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';
import 'package:nasam/features/poi/presentation/pages/poi_page.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_datasource.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_fixture_datasource.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_asset_details_page.dart';
import 'package:nasam/features/tracking/presentation/pages/tracking_page.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_asset_not_found.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fake_map_platform.dart';
import '../../helpers/fixture_bundle.dart';
import '../../helpers/poi_files.dart';

/// The real [AppRouter] and guard, opened the way the OS opens a link: the
/// platform's initial route is set before the router exists, so go_router
/// starts there rather than at splash. Only the edges are faked — the
/// session, the login call, the map plugin and asset IO.

class _FakeAuthService implements AuthService {
  bool signedIn = false;

  @override
  Future<bool> get isAuthenticated async => signedIn;
  @override
  Future<String?> get accessToken async => signedIn ? 'token' : null;
  @override
  Future<String?> get currentUser async => null;
}

class _MockLogin extends Mock implements LoginUseCase {}

class _MockSession extends Mock implements AuthSessionEntity {}

/// An asset the fixture has.
const _knownId = 'AST-0017';

void main() {
  late _FakeAuthService auth;
  late _MockLogin login;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await configureDependencies(
      const AppConfig(
        flavor: Flavor.dev,
        appName: 'Nasam',
        baseUrl: 'https://api-dev.nasam.app/v1',
        wsUrl: 'wss://ws-dev.nasam.app',
        tenant: 'test-tenant',
      ),
    );
    getIt.allowReassignment = true;

    auth = _FakeAuthService()..signedIn = true;
    login = _MockLogin();
    getIt
      ..registerSingleton<AuthService>(auth)
      ..registerSingleton<LoginUseCase>(login)
      ..registerSingleton<TrackingDataSource>(
        TrackingFixtureDataSource(
          bundle: DiskAssetBundle(),
          latency: Duration.zero,
        ),
      )
      ..registerSingleton<PoiDataSource>(
        PoiFixtureDataSource(bundle: DiskAssetBundle()),
      )
      ..registerSingleton<PlaybackDataSource>(
        PlaybackFixtureDataSource(
          bundle: DiskAssetBundle(),
          latency: Duration.zero,
        ),
      );
    GoogleMapsFlutterPlatform.instance = FakeMapPlatform();
  });

  tearDown(() async {
    getIt.allowReassignment = false;
    await getIt.reset();
  });

  Future<AppRouter> open(WidgetTester tester, String location) =>
      openApp(tester, location);

  String location(AppRouter router) => currentLocation(router);

  /// The system back gesture, as the OS delivers it.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Home drawer switches to POI and retains tracking and POI state',
    (tester) async {
      final router = await open(tester, AppRoutes.home);
      router.config.go(AppRoutes.home);
      await tester.pumpAndSettle();
      final tracking = tester
          .element(find.byType(TrackingPage))
          .read<TrackingCubit>();
      tracking.onQueryChanged('truck');
      await tester.pump(const Duration(milliseconds: 350));
      final drawer = tester
          .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
          .controller!;
      drawer.showDrawer();
      await tester.pumpAndSettle();
      final menu = tester.widget<AppDrawer>(find.byType(AppDrawer));
      expect(menu.available, contains(DrawerDestination.pointsOfInterest));
      menu.onSelect!(DrawerDestination.pointsOfInterest);
      await tester.pumpAndSettle();
      expect(location(router), AppRoutes.poi);
      expect(find.byType(PoiPage), findsOneWidget);
      final poi = tester.element(find.byType(PoiPage)).read<PoiCubit>();
      poi.search('Manhole');
      await tester.pumpAndSettle();
      drawer.showDrawer();
      await tester.pumpAndSettle();
      await back(tester); // First closes the drawer, keeping POI selected.
      expect(location(router), AppRoutes.poi);
      expect(drawer.value.visible, isFalse);
      await back(tester); // Then returns to tracking within Home.
      expect(location(router), AppRoutes.home);
      expect(
        tester.element(find.byType(TrackingPage)).read<TrackingCubit>(),
        same(tracking),
      );
      expect(tracking.state.visible!.query, 'truck');
      router.config.go(AppRoutes.poi);
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(PoiPage)).read<PoiCubit>(), same(poi));
      expect(poi.state.query, 'Manhole');
    },
  );

  testWidgets('a cold POI link opens in Home and back returns to tracking', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.poi);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(PoiPage), findsOneWidget);
    expect(
      tester.widget<AppDrawer>(find.byType(AppDrawer)).selected,
      DrawerDestination.pointsOfInterest,
    );
    await back(tester);
    expect(location(router), AppRoutes.home);
  });

  testWidgets('POI create, view, edit and confirmed delete refresh Home', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.poi);
    await tester.tap(find.text('Add POI'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiEditorPage), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New warehouse');
    await tester.enterText(fields.at(1), '24.8');
    await tester.enterText(fields.at(2), '46.4');
    await tester.tap(find.text('Create POI'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiPage), findsOneWidget);
    final poi = tester.element(find.byType(PoiPage)).read<PoiCubit>();
    final point = poi.state.points.singleWhere(
      (p) => p.name == 'New warehouse',
    );
    expect(poi.state.points.length, 5);
    unawaited(router.config.push(AppRoutes.poiDetails(point.id)));
    await tester.pumpAndSettle();
    expect(find.byType(PoiDetailsPage), findsOneWidget);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Updated warehouse');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated warehouse'), findsWidgets);
    await tester.ensureVisible(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiDetailsPage), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiPage), findsOneWidget);
    expect((await getIt<PoiRepository>().getPoint(point.id)).isLeft(), isTrue);
    expect(poi.state.points.length, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'POI dirty draft stays after cancelled discard and unknown links show not-found',
    (tester) async {
      final router = await open(tester, AppRoutes.poiCreate);
      await tester.enterText(find.byType(TextField).first, 'Draft');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Draft'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(PoiPage), findsOneWidget);
      router.config.go(AppRoutes.poiDetails('missing'));
      await tester.pumpAndSettle();
      expect(find.text('Point of interest not found'), findsOneWidget);
      await back(tester);
      expect(find.byType(PoiPage), findsOneWidget);
    },
  );

  testWidgets(
    'POI upload walks validation, preview and confirmation with actual counts',
    (tester) async {
      getIt.registerSingleton<PoiFiles>(
        FakePoiFiles()
          ..selected = const PickedPoiWorkbook('points.xlsx', [
            ['name', 'latitude', 'longitude', 'icon', 'notes'],
            ['New', '24', '46', 'fuel', ''],
            ['Bad', '999', '46', 'fuel', ''],
            ['New', '24', '46', 'fuel', ''],
          ]),
      );
      await open(tester, AppRoutes.poi);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse files'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Validate'));
      await tester.pumpAndSettle();
      expect(find.text('Valid (1)'), findsOneWidget);
      expect(find.text('Invalid (1)'), findsOneWidget);
      expect(find.text('Duplicate (1)'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Bad'), findsNothing);
      await tester.tap(find.widgetWithText(AppButton, 'Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('POI import complete'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(AppButton, 'Show points on the map'),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(PoiPage))
            .read<PoiCubit>()
            .state
            .points
            .length,
        5,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a cold link to details opens it over home; back goes home', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.assetDetails(_knownId));

    expect(location(router), '/assets/$_knownId');
    expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);
    expect(find.text(_knownId), findsWidgets, reason: 'resolved from the id');

    await back(tester);

    expect(location(router), AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(TrackingAssetDetailsPage), findsNothing);
  });

  testWidgets('a cold link to playback backs out through details to home', (
    tester,
  ) async {
    final router = await open(tester, AppRoutes.assetPlayback(_knownId));

    expect(find.byType(PlaybackPage), findsOneWidget);
    expect(
      find.textContaining(_knownId),
      findsWidgets,
      reason: 'header from the id',
    );

    await back(tester);
    expect(location(router), '/assets/$_knownId');
    expect(find.byType(TrackingAssetDetailsPage), findsOneWidget);

    await back(tester);
    expect(location(router), AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('a valid range in the link reaches the page', (tester) async {
    final today = PlaybackRange.today();
    final from = today.from.subtract(const Duration(days: 3));
    await open(tester, AppRoutes.assetPlayback(_knownId, from: from));

    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange.from, from);
    expect(page.initialRange.to, today.to, reason: 'no to: through today');
  });

  testWidgets('an invalid range in the link falls back to today', (
    tester,
  ) async {
    await open(
      tester,
      '/assets/$_knownId/playback?from=not-a-date&to=2999-01-01',
    );

    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange, PlaybackRange.today());
    expect(tester.takeException(), isNull);
  });

  for (final link in [
    AppRoutes.assetDetails('NO-SUCH-ASSET'),
    AppRoutes.assetPlayback('NO-SUCH-ASSET'),
    '/assets/%20',
  ]) {
    testWidgets('unknown id $link shows not-found, with a way home', (
      tester,
    ) async {
      final router = await open(tester, link);

      expect(find.byType(TrackingAssetNotFound), findsOneWidget);
      expect(location(router), startsWith('/assets/'), reason: 'no redirect');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      expect(location(router), AppRoutes.home);
      expect(find.byType(HomePage), findsOneWidget);
    });
  }

  testWidgets('signed out, a deep link goes through login and on to it', (
    tester,
  ) async {
    auth.signedIn = false;
    when(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      auth.signedIn = true;
      return Right(LoginSucceeded(_MockSession()));
    });
    final day = PlaybackRange.today().from;
    final from = day.subtract(const Duration(days: 5));
    final to = day.subtract(const Duration(days: 2));
    final target = AppRoutes.assetPlayback(_knownId, from: from, to: to);

    final router = await open(tester, target);

    expect(find.byType(LoginPage), findsOneWidget);
    final atLogin = Uri.parse(location(router));
    expect(atLogin.path, AppRoutes.login);
    expect(atLogin.queryParameters[AppRoutes.returnToParam], target);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'aya');
    await tester.enterText(fields.at(1), 'correct horse');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(location(router), target);
    final page = tester.widget<PlaybackPage>(find.byType(PlaybackPage));
    expect(page.initialRange.from, from, reason: 'dates survive the detour');
    expect(page.initialRange.to, to);
  });

  testWidgets('a hostile login target lands on home after sign-in', (
    tester,
  ) async {
    auth.signedIn = false;
    when(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      auth.signedIn = true;
      return Right(LoginSucceeded(_MockSession()));
    });

    final router = await open(
      tester,
      AppRoutes.loginReturningTo('//evil.example/phish'),
    );
    expect(find.byType(LoginPage), findsOneWidget);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'aya');
    await tester.enterText(fields.at(1), 'correct horse');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(location(router), AppRoutes.home);
  });
}
