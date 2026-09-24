import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/features/auth/domain/entities/user_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';
import 'package:nasam/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/current_user_cubit.dart';
import 'package:nasam/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracking_vehicles_usecase.dart';
import 'package:nasam/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:nasam/features/tracking/presentation/tracking_page.dart';

import 'fake_map_platform.dart';
import 'fixture_bundle.dart';
import 'widget_harness.dart';

class _MockLogout extends Mock implements LogoutUseCase {}

class _MockGetCurrentUser extends Mock implements GetCurrentUserUseCase {}

/// The user the fakes report as signed in.
const signedInUser = UserEntity(
  id: 'user-1',
  username: 'aya',
  email: 'aya@nasam.sa',
  nameEn: 'Aya Al-Rashidi',
  nameAr: null,
  account: null,
  type: UserType.admin,
  permissions: [],
);

/// Registers what the tracking screen's drawer resolves from the container,
/// with fakes, and removes them after the test.
void registerTrackingScreenFakes() {
  if (getIt.isRegistered<LogoutCubit>()) return;
  final logout = _MockLogout();
  when(logout.call).thenAnswer((_) async => const Right(unit));
  final currentUser = _MockGetCurrentUser();
  when(currentUser.call).thenAnswer((_) async => const Right(signedInUser));
  getIt
    ..registerFactory<LogoutCubit>(() => LogoutCubit(logout))
    ..registerFactory<CurrentUserCubit>(() => CurrentUserCubit(currentUser));
  addTearDown(() {
    getIt
      ..unregister<LogoutCubit>()
      ..unregister<CurrentUserCubit>();
  });
}

/// The tracking screen as the router builds it, over the JSON fixtures.
Widget trackingScreen() {
  final repository = fixtureTrackingRepository();
  return BlocProvider(
    create: (_) => TrackingCubit(
      GetTrackingVehiclesUseCase(repository),
      GetTrackedAssetsUseCase(repository),
    )..load(),
    child: const TrackingPage(),
  );
}

/// Pumps [trackingScreen] on a [size] screen at [textScale], with the map
/// faked and the drawer's dependencies registered.
Future<void> pumpTrackingScreen(
  WidgetTester tester, {
  Size size = const Size(360, 640),
  double textScale = 1,
  Locale locale = const Locale('en'),
  bool dark = false,
  FakeMapPlatform? platform,
  Widget Function(Widget screen)? wrap,
}) async {
  GoogleMapsFlutterPlatform.instance = platform ?? FakeMapPlatform();
  registerTrackingScreenFakes();
  await pumpInApp(
    tester,
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: (wrap ?? (screen) => screen)(trackingScreen()),
      ),
    ),
    locale: locale,
    dark: dark,
  );
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
}
