# Nasam — Engineering Reference Guide

> **Version:** 1.0.0  
> **Last Updated:** June 2026  
> **Platform:** iOS & Android  
> **Domain:** Fleet Management — Real-time Vehicle Tracking  

This document is the single source of truth for every engineering decision in the Nasam project.
Every developer, every AI assistant, and every code review must align with what is written here.

---

## Table of Contents

1. [Architecture Decisions & Rules](#1-architecture-decisions--rules)
2. [Folder Structure](#2-folder-structure)
3. [Packages & Dependencies](#3-packages--dependencies)
4. [Code Patterns & Examples](#4-code-patterns--examples)
5. [Security Rules & Checklist](#5-security-rules--checklist)
6. [Responsive & UI Conventions](#6-responsive--ui-conventions)
7. [Naming Conventions & Clean Code](#7-naming-conventions--clean-code)
8. [How to Add a New Feature](#8-how-to-add-a-new-feature)
9. [Testing Strategy & Conventions](#9-testing-strategy--conventions)

---

## 1. Architecture Decisions & Rules

### Why Clean Architecture?

Nasam is a long-lived, team-scale fleet management system with:
- Real-time WebSocket streams alongside standard REST APIs
- Complex domain logic (geo-fencing, route deviation, vehicle state machines)
- Multiple developers working in parallel on isolated features
- A requirement to swap implementations (e.g. map provider, auth mechanism) without touching UI

Clean Architecture enforces a strict boundary between **what the app does** (domain) and **how it does it** (data + infrastructure). This means the business rules never break when we swap Dio for another HTTP client, or change the map provider.

### The Three Layers

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │  ← BLoC, Pages, Widgets
│  Knows about: Domain                    │
│  Must NOT know about: Data, APIs, DB    │
├─────────────────────────────────────────┤
│             DOMAIN LAYER                │  ← Entities, UseCases, Repository interfaces
│  Knows about: nothing external          │
│  Pure Dart only. Zero Flutter imports.  │
├─────────────────────────────────────────┤
│              DATA LAYER                 │  ← DTOs, DataSources, Repository impls
│  Knows about: Domain                    │
│  Must NOT know about: Presentation      │
└─────────────────────────────────────────┘
```

**Dependency Rule:** Dependencies always point inward. Data → Domain ← Presentation. Never outward.

### Why BLoC (not Riverpod or Provider)?

| Reason | Explanation |
|--------|-------------|
| Event-driven domain | Fleet tracking is inherently event-driven: `VehicleLocationUpdated`, `TaskAssigned`, `WebSocketReconnected`. BLoC's explicit event model maps directly to these domain events. |
| Auditability | Every state transition is traceable through `AppBlocObserver`. Critical for debugging real-time bugs. |
| GetIt separation | BLoC + GetIt/Injectable are non-overlapping. Riverpod doubles as a DI container, creating architectural tension with Injectable. |
| Stream support | `on<Event>()` with `emit.forEach()` handles WebSocket streams natively and cleanly. |
| Team clarity | The Event → BLoC → State pattern is explicit and opinionated. Less "anything goes" ambiguity at team scale. |

### Why Injectable over manual GetIt?

Manual GetIt registration centralizes all wiring into one growing file. By feature 8+, it becomes a 400-line unmaintainable mess with "forgot to register" runtime crashes.

Injectable uses annotations (`@injectable`, `@lazySingleton`, `@module`) to auto-generate registration code via `build_runner`. Each class self-documents its own lifetime. Zero "forgot to register" bugs — they become compile errors.

### Why Freezed?

Every BLoC state must be immutable and equality-comparable. Without `==` equality, BLoC cannot detect whether state changed and will trigger unnecessary UI rebuilds. Writing `copyWith`, `==`, `hashCode`, and `toString` manually per class is ~40 lines of boilerplate and a constant source of bugs. Freezed generates all of this from a single annotation and enforces exhaustive pattern matching on sealed unions.

### Why Dartz (`Either<Failure, T>`)?

Raw exceptions thrown across layers violate Clean Architecture — the UI should never catch a `DioException`. Dartz's `Either` type forces the caller to handle both success and failure explicitly at compile time. A `Right(data)` means success. A `Left(Failure)` means a typed, domain-level error that the UI knows how to display. No swallowed exceptions. No runtime surprises.

### Why GoRouter?

GoRouter is the Flutter team's official declarative router. It supports deep links, type-safe routes, redirect guards (auth protection), and nested `ShellRoute` for bottom navigation — all required for a fleet app. Navigator 1.0 does not scale to this complexity.

### Architecture Non-Negotiables

- ❌ **Never** import a `data/` class directly in `presentation/`
- ❌ **Never** import Flutter in `domain/`
- ❌ **Never** call a repository directly from a BLoC — always through a UseCase
- ❌ **Never** catch exceptions in `presentation/` — only handle `Failure` types
- ❌ **Never** put business logic inside a widget's `build()` or `onPressed()`
- ❌ **Never** use `Navigator.push` directly — always use GoRouter
- ❌ **Never** use `print()` — always use `AppLogger`
- ❌ **Never** hardcode a color, string, size, or URL anywhere

---

## 2. Folder Structure

```
nasam/
├── lib/
│   ├── main.dart                          # App entry point. Init order is strict (see below).
│   │
│   ├── app/
│   │   ├── app.dart                       # MaterialApp.router. ScreenUtil + l10n wired here.
│   │   └── app_bloc_observer.dart         # Global BLoC lifecycle logger.
│   │
│   ├── core/                              # Shared infrastructure. Features depend on this. Never the reverse.
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Single source of truth for all colors.
│   │   │   ├── app_text_styles.dart       # All TextStyles. Reference AppColors + AppSizes only.
│   │   │   ├── app_sizes.dart             # Spacing, radius, icon sizes as named constants.
│   │   │   ├── app_assets.dart            # All asset paths as static const strings.
│   │   │   ├── app_strings.dart           # Non-translatable strings (keys, tags, identifiers).
│   │   │   └── app_constants.dart         # Timeouts, pagination limits, WebSocket config.
│   │   │
│   │   ├── errors/
│   │   │   ├── failures.dart              # Sealed Failure hierarchy (see Section 4).
│   │   │   └── exceptions.dart            # Internal AppException types (never exposed to UI).
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Dio singleton. BaseOptions from .env.
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart  # Attaches token. Handles 401 + refresh.
│   │   │       ├── logging_interceptor.dart # Logs req/res. Never logs tokens or PII.
│   │   │       └── error_interceptor.dart # Maps DioException → typed Failure.
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart            # GoRouter instance. All routes declared here.
│   │   │   ├── app_routes.dart            # Route path constants. No magic strings.
│   │   │   └── route_guard.dart           # Auth redirect logic.
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # ThemeData factory: light() and dark().
│   │   │   └── app_theme_data.dart        # Component-level theme overrides.
│   │   │
│   │   ├── localization/
│   │   │   ├── app_localizations_setup.dart  # Delegates + supportedLocales.
│   │   │   └── l10n/
│   │   │       ├── app_en.arb             # English strings.
│   │   │       └── app_ar.arb             # Arabic strings. RTL-safe values.
│   │   │
│   │   ├── responsive/
│   │   │   ├── breakpoints.dart           # mobileMax=600, tabletMax=1024.
│   │   │   └── responsive_layout.dart     # ResponsiveLayout widget.
│   │   │
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart    # context.tr(), context.screenWidth, context.isRTL
│   │   │   ├── string_extensions.dart     # isNullOrEmpty, truncate, toArabicNumerals
│   │   │   └── date_extensions.dart       # toFormattedString, isToday, toRelativeTime
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart            # All form validators. See Section 4.
│   │   │   ├── app_date_utils.dart        # Date formatting. Hijri-aware.
│   │   │   └── app_logger.dart            # Logger wrapper. debug/info/warning/error.
│   │   │
│   │   ├── services/
│   │   │   ├── auth_service.dart          # Abstract interface. JWT/OAuth ready.
│   │   │   ├── secure_storage_service.dart # flutter_secure_storage wrapper.
│   │   │   ├── storage_service.dart       # SharedPreferences wrapper (non-sensitive only).
│   │   │   └── websocket_service.dart     # WebSocket + auto-reconnect + backoff.
│   │   │
│   │   └── di/
│   │       ├── injection_container.dart   # configureDependencies() entry point.
│   │       └── modules/
│   │           ├── network_module.dart    # @module: Dio, interceptors.
│   │           ├── storage_module.dart    # @module: SecureStorage, SharedPrefs.
│   │           └── service_module.dart    # @module: AuthService, WebSocketService.
│   │
│   ├── shared/
│   │   └── widgets/                       # Reusable across ALL features.
│   │       ├── app_scaffold.dart          # Base scaffold wrapper.
│   │       ├── app_bar_widget.dart        # Branded NasamAppBar.
│   │       ├── app_drawer.dart            # Side drawer. RTL-aware.
│   │       ├── app_button.dart            # primary / secondary / outline / danger / loading.
│   │       ├── app_text_field.dart        # Validated input with RTL support.
│   │       ├── app_card.dart              # Base card container.
│   │       ├── app_dialog.dart            # confirm / info / error variants.
│   │       ├── app_bottom_sheet.dart      # show() static method.
│   │       ├── app_snack_bar.dart         # success / error / info / warning.
│   │       ├── loading_widget.dart        # Full-screen + inline variants.
│   │       ├── error_widget.dart          # Error state + retry callback.
│   │       └── empty_state_widget.dart    # Empty state + optional action.
│   │
│   └── features/
│       └── <feature_name>/               # Copy from _template/. One folder per feature.
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── remote/            # API calls via Dio.
│           │   │   └── local/             # Cache via SharedPrefs or DB.
│           │   ├── models/                # DTOs: fromJson / toJson (Freezed + json_serializable).
│           │   ├── mappers/               # Pure functions: DTO → Entity.
│           │   └── repositories/          # Implements domain repository interface.
│           ├── domain/
│           │   ├── entities/              # Pure Dart. Freezed. Zero external imports.
│           │   ├── repositories/          # Abstract interface only.
│           │   └── usecases/              # One use case per file. Single call() method.
│           └── presentation/
│               ├── bloc/                  # BLoC + Event + State (Freezed sealed).
│               ├── pages/                 # Full-screen widgets. No business logic.
│               └── widgets/               # Private to this feature.
│
└── test/
    ├── helpers/
    │   ├── test_helper.dart               # Shared setUp, common fakes.
    │   └── mock_helper.dart               # Mocktail mock declarations.
    ├── core/
    │   └── utils/validators_test.dart     # Full coverage for all validators.
    └── features/
        └── <feature_name>/
            ├── data/repositories/         # Repository impl tests.
            ├── domain/usecases/           # UseCase tests.
            └── presentation/bloc/         # BLoC tests via bloc_test.
```

### main.dart Initialization Order (strict — do not reorder)

```dart
void main() async {
  // 1. Flutter engine binding
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Environment config (must be before DI — DI reads from .env)
  await dotenv.load(fileName: '.env');
  // 3. Dependency injection
  await configureDependencies();
  // 4. BLoC observer
  Bloc.observer = AppBlocObserver();
  // 5. Orientation lock
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 6. Run
  runApp(const NasamApp());
}
```

---

## 3. Packages & Dependencies

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.5 | BLoC/Cubit state management |
| `bloc_concurrency` | ^0.2.5 | Event transformers: `droppable()`, `restartable()` for real-time events |
| `get_it` | ^7.7.0 | Service locator (used under the hood by Injectable) |
| `injectable` | ^2.4.1 | Annotation-based DI code generation on top of GetIt |
| `freezed_annotation` | ^2.4.1 | Immutable classes, sealed unions, copyWith, pattern matching |
| `json_annotation` | ^4.9.0 | JSON serialization annotations for DTOs |
| `dartz` | ^0.10.1 | `Either<Failure, T>` for typed functional error handling |
| `dio` | ^5.4.3 | HTTP client with interceptor pipeline |
| `connectivity_plus` | ^6.0.3 | Network connectivity detection |
| `web_socket_channel` | ^3.0.1 | WebSocket support for real-time vehicle tracking |
| `go_router` | ^13.2.0 | Declarative routing, deep links, auth guards, ShellRoute |
| `flutter_screenutil` | ^5.9.1 | Responsive scaling: `.w`, `.h`, `.r`, `.sp` |
| `flutter_secure_storage` | ^9.2.2 | Keychain (iOS) / Keystore (Android) for tokens |
| `safe_device` | ^1.1.4 | Root/jailbreak detection |
| `flutter_dotenv` | ^5.1.0 | `.env` file loading — no hardcoded URLs or keys |
| `shared_preferences` | ^2.2.3 | Non-sensitive local storage (theme, locale preference) |
| `logger` | ^2.3.0 | Structured logging with levels. Replaces `print()` everywhere |
| `intl` | ^0.19.0 | Internationalization, date formatting, Arabic numeral support |
| `flutter_localizations` | SDK | Built-in localization delegates |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.9 | Code generation runner for Freezed, Injectable, json_serializable |
| `freezed` | ^2.5.2 | Generator for Freezed annotations |
| `json_serializable` | ^6.8.0 | Generator for fromJson/toJson |
| `injectable_generator` | ^2.4.2 | Generator for Injectable DI registrations |
| `mocktail` | ^1.0.3 | Mock library for unit tests (no code-gen needed) |
| `bloc_test` | ^9.1.7 | `blocTest()` helper for testing BLoC state sequences |
| `faker` | ^2.1.0 | Realistic test data generation |
| `flutter_lints` | ^4.0.0 | Flutter-recommended lint rules |

### Code Generation Command

Run after any change to annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Code Patterns & Examples

### Failure Hierarchy

```dart
// core/errors/failures.dart

sealed class Failure {
  const Failure({required this.message, this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;
}

class NetworkFailure    extends Failure {
  const NetworkFailure({required super.message, super.code, super.stackTrace});
}
class ServerFailure     extends Failure {
  const ServerFailure({required super.message, super.code, super.stackTrace});
}
class AuthFailure       extends Failure {
  const AuthFailure({required super.message, super.code});
}
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
class CacheFailure      extends Failure {
  const CacheFailure({required super.message, super.stackTrace});
}
class TimeoutFailure    extends Failure {
  const TimeoutFailure({required super.message});
}
class UnknownFailure    extends Failure {
  const UnknownFailure({required super.message, super.stackTrace});
}
```

**HTTP Status → Failure Mapping:**

| HTTP / Exception | Failure Type |
|-----------------|--------------|
| `SocketException` | `NetworkFailure` |
| `connectionTimeout` | `NetworkFailure` |
| `receiveTimeout` | `TimeoutFailure` |
| `sendTimeout` | `TimeoutFailure` |
| 401 | `AuthFailure` |
| 403 | `PermissionFailure` |
| 404 | `ServerFailure(code: '404')` |
| 422 | `ValidationFailure` |
| 5xx | `ServerFailure` |
| Unknown | `UnknownFailure` |

---

### Domain Entity (Freezed)

```dart
// features/vehicle/domain/entities/vehicle_entity.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_entity.freezed.dart';

@freezed
class VehicleEntity with _$VehicleEntity {
  const factory VehicleEntity({
    required String id,
    required String plateNumber,
    required double latitude,
    required double longitude,
    required VehicleStatus status,
    required DateTime lastUpdated,
  }) = _VehicleEntity;
}

enum VehicleStatus { active, idle, offline, maintenance }

// ✅ Pure Dart — zero Flutter/Dio/DB imports
// ✅ Freezed gives: copyWith, ==, hashCode, toString for free
```

---

### DTO Model (Data Layer)

```dart
// features/vehicle/data/models/vehicle_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String id,
    @JsonKey(name: 'plate_number') required String plateNumber,
    required double latitude,
    required double longitude,
    required String status,
    @JsonKey(name: 'last_updated') required String lastUpdated,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
}
```

---

### Mapper (DTO → Entity)

```dart
// features/vehicle/data/mappers/vehicle_mapper.dart

import '../models/vehicle_model.dart';
import '../../domain/entities/vehicle_entity.dart';

// Pure functions — no class needed, no state
VehicleEntity vehicleModelToEntity(VehicleModel model) => VehicleEntity(
  id: model.id,
  plateNumber: model.plateNumber,
  latitude: model.latitude,
  longitude: model.longitude,
  status: _mapStatus(model.status),
  lastUpdated: DateTime.parse(model.lastUpdated),
);

VehicleStatus _mapStatus(String raw) => switch (raw) {
  'active'      => VehicleStatus.active,
  'idle'        => VehicleStatus.idle,
  'offline'     => VehicleStatus.offline,
  'maintenance' => VehicleStatus.maintenance,
  _             => VehicleStatus.offline,
};
```

---

### Repository Interface (Domain)

```dart
// features/vehicle/domain/repositories/vehicle_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<Either<Failure, List<VehicleEntity>>> getVehicles();
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);
  Stream<Either<Failure, VehicleEntity>> trackVehicle(String id);
}
```

---

### Repository Implementation (Data)

```dart
// features/vehicle/data/repositories/vehicle_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/remote/vehicle_remote_datasource.dart';
import '../mappers/vehicle_mapper.dart';

@Injectable(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl(this._remote);
  final VehicleRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles() async {
    try {
      final models = await _remote.fetchVehicles();
      return Right(models.map(vehicleModelToEntity).toList());
    } on SocketException catch (e, st) {
      return Left(NetworkFailure(message: e.message, stackTrace: st));
    } on DioException catch (e, st) {
      return Left(_mapDioError(e, st));
    } catch (e, st) {
      return Left(UnknownFailure(message: e.toString(), stackTrace: st));
    }
  }

  Failure _mapDioError(DioException e, StackTrace st) =>
      switch (e.response?.statusCode) {
        401 => const AuthFailure(message: 'Unauthorized'),
        403 => const PermissionFailure(message: 'Forbidden'),
        404 => const ServerFailure(message: 'Not found', code: '404'),
        422 => const ValidationFailure(message: 'Validation error'),
        >= 500 => ServerFailure(message: 'Server error', stackTrace: st),
        _ => switch (e.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.sendTimeout =>
            TimeoutFailure(message: 'Request timed out'),
          _ => UnknownFailure(message: e.message ?? 'Unknown', stackTrace: st),
        },
      };
}
```

---

### UseCase (Domain)

```dart
// features/vehicle/domain/usecases/get_vehicles_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class GetVehiclesUseCase {
  const GetVehiclesUseCase(this._repository);
  final VehicleRepository _repository;

  // Single public method. Always call().
  Future<Either<Failure, List<VehicleEntity>>> call() =>
      _repository.getVehicles();
}
```

---

### BLoC — Event, State, BLoC

```dart
// features/vehicle/presentation/bloc/vehicle_event.dart

part of 'vehicle_bloc.dart';

@freezed
class VehicleEvent with _$VehicleEvent {
  const factory VehicleEvent.started()                  = _Started;
  const factory VehicleEvent.refreshRequested()         = _RefreshRequested;
  const factory VehicleEvent.vehicleSelected(String id) = _VehicleSelected;
}
```

```dart
// features/vehicle/presentation/bloc/vehicle_state.dart

part of 'vehicle_bloc.dart';

@freezed
class VehicleState with _$VehicleState {
  const factory VehicleState.initial()                              = _Initial;
  const factory VehicleState.loading()                              = _Loading;
  const factory VehicleState.loaded(List<VehicleEntity> vehicles)  = _Loaded;
  const factory VehicleState.failure(Failure failure)              = _Failure;
}
```

```dart
// features/vehicle/presentation/bloc/vehicle_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';

part 'vehicle_bloc.freezed.dart';
part 'vehicle_event.dart';
part 'vehicle_state.dart';

@injectable
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc(this._getVehicles) : super(const VehicleState.initial()) {
    on<_Started>(_onStarted);
    on<_RefreshRequested>(_onRefreshRequested);
  }

  final GetVehiclesUseCase _getVehicles;

  Future<void> _onStarted(_Started event, Emitter<VehicleState> emit) =>
      _fetchVehicles(emit);

  Future<void> _onRefreshRequested(
    _RefreshRequested event,
    Emitter<VehicleState> emit,
  ) => _fetchVehicles(emit);

  Future<void> _fetchVehicles(Emitter<VehicleState> emit) async {
    emit(const VehicleState.loading());
    final result = await _getVehicles();
    result.fold(
      (failure) => emit(VehicleState.failure(failure)),
      (vehicles) => emit(VehicleState.loaded(vehicles)),
    );
  }
}
```

---

### Page (Presentation)

```dart
// features/vehicle/presentation/pages/vehicle_list_page.dart

class VehicleListPage extends StatelessWidget {
  const VehicleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VehicleBloc>()..add(const VehicleEvent.started()),
      child: const _VehicleListView(),
    );
  }
}

class _VehicleListView extends StatelessWidget {
  const _VehicleListView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: NasamAppBar(title: context.tr('vehicles')),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const LoadingWidget(),
          loaded: (vehicles) => _VehicleList(vehicles: vehicles),
          failure: (failure) => ErrorStateWidget(
            message: failure.message,
            onRetry: () => context
                .read<VehicleBloc>()
                .add(const VehicleEvent.refreshRequested()),
          ),
        ),
      ),
    );
  }
}
```

---

### Validators

```dart
// core/utils/validators.dart

class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain an uppercase letter';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Must contain a lowercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a digit';
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return 'Must contain a special character';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? saudiPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^((\+966)|0)?5[0-9]{8}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid Saudi phone number';
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value != null && value.length < min) return 'Minimum $min characters';
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value != null && value.length > max) return 'Maximum $max characters';
    return null;
  }

  static String? numeric(String? value) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Must be a number';
    return null;
  }

  static String? arabicOnly(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value)) {
      return 'Arabic text only';
    }
    return null;
  }

  static String? latitude(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed < -90 || parsed > 90) {
      return 'Invalid latitude (-90 to 90)';
    }
    return null;
  }

  static String? longitude(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed < -180 || parsed > 180) {
      return 'Invalid longitude (-180 to 180)';
    }
    return null;
  }

  static String? saudiPlateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Plate number is required';
    final regex = RegExp(r'^[A-Z]{3}\s?[0-9]{4}$');
    if (!regex.hasMatch(value.trim().toUpperCase())) {
      return 'Invalid Saudi plate number (e.g. ABC 1234)';
    }
    return null;
  }

  // Compose multiple validators — runs all, returns first error
  static String? compose(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
```

---

### GoRouter Setup

```dart
// core/router/app_router.dart

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  redirect: RouteGuard.evaluate,
  errorBuilder: (context, state) => const AppErrorPage(),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(body: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.vehicles,
          builder: (context, state) => const VehicleListPage(),
        ),
      ],
    ),
  ],
);

// core/router/app_routes.dart
abstract class AppRoutes {
  static const splash    = '/splash';
  static const login     = '/login';
  static const dashboard = '/dashboard';
  static const vehicles  = '/vehicles';
}
```

---

### WebSocket Service Pattern

```dart
// core/services/websocket_service.dart

enum WsConnectionState { connecting, connected, disconnected, error }

abstract class WebSocketService {
  Stream<dynamic> get messages;
  Stream<WsConnectionState> get connectionState;
  Future<void> connect(String url);
  void disconnect();
  void send(dynamic data);
}

// Implementation uses exponential backoff:
// Attempt 1: wait 1s → Attempt 2: wait 2s → Attempt 3: wait 4s → max 30s
```

---

## 5. Security Rules & Checklist

### Token Storage — Rule

**All authentication tokens MUST be stored in `flutter_secure_storage`.**
Never use `SharedPreferences` for tokens. Never hardcode tokens anywhere.

```dart
// ✅ Correct
await secureStorage.write(key: 'access_token', value: token);

// ❌ Never
SharedPreferences.getInstance().then((p) => p.setString('token', token));
const token = 'eyJhbGci...'; // hardcoded
```

### Environment Config — Rule

All URLs, API keys, timeouts, and WebSocket addresses live in `.env`.
`.env` is **always gitignored**. Never committed. Never hardcoded.

```
# .env
BASE_URL=https://api.nasam.app/v1
WS_URL=wss://ws.nasam.app
CONNECT_TIMEOUT_MS=15000
RECEIVE_TIMEOUT_MS=30000
```

Access via:
```dart
dotenv.env['BASE_URL'] ?? ''
```

### Anti Reverse Engineering

All release builds MUST use these flags:

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=.env
```

Android ProGuard is enabled in `release` build type. Never disable.

### Root / Jailbreak Detection

Check on app startup. Restrict access if compromised:

```dart
final isCompromised = await SafeDevice.isJailBroken || await SafeDevice.isRooted;
if (isCompromised) {
  // Show warning page — do not load sensitive data
}
```

### Logging Rules

```dart
// ✅ Log: request URLs, response status codes, failure types, timestamps
AppLogger.info('GET /vehicles → 200');
AppLogger.error('VehicleRepository.getVehicles failed', error: failure);

// ❌ NEVER log: tokens, passwords, PII, coordinates, plate numbers
```

### Network Security Rules

- All API calls over HTTPS — no HTTP in production
- `AuthInterceptor` attaches `Bearer` token from `SecureStorageService`
- On 401: refresh token once, retry, then emit `AuthFailure` (redirect to login)
- Structure is ready for certificate pinning — add `badCertificateCallback` to `IOHttpClientAdapter` when required

### Security Pre-Release Checklist

- [ ] No API keys or URLs hardcoded anywhere in `lib/`
- [ ] `.env` is in `.gitignore` and not committed
- [ ] All tokens stored in `flutter_secure_storage`
- [ ] Release build uses `--obfuscate` flag
- [ ] Release build uses `--split-debug-info`
- [ ] ProGuard enabled on Android release
- [ ] Root/jailbreak check runs on app startup
- [ ] No sensitive data in any log statement
- [ ] `AuthInterceptor` handles 401 refresh correctly
- [ ] HTTPS enforced — no plain HTTP endpoints
- [ ] Input validation on every user-facing form field

---

## 6. Responsive & UI Conventions

### Strategy

Nasam uses **one consistent design** across mobile and tablet — no layout switching.
`flutter_screenutil` scales all spacing, typography, and sizes proportionally.

**Design base size:** `375 × 812` (iPhone 13 portrait)

### ScreenUtil Usage

```dart
// Sizes
SizedBox(height: 16.h)       // height scaled
SizedBox(width: 24.w)        // width scaled
BorderRadius.circular(8.r)   // radius scaled

// Typography
TextStyle(fontSize: 14.sp)   // font size scaled

// ✅ Never hardcode raw pixel values
// ❌ SizedBox(height: 16)   ← breaks on other screen sizes
```

### ScreenUtil Initialization

```dart
// app/app.dart — wrap MaterialApp.router
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: false,
  builder: (context, child) => MaterialApp.router(...)
)
```

### Breakpoints (reference only — layout does not switch)

```dart
// core/responsive/breakpoints.dart
abstract class Breakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileMax && w < tabletMax;
  }
}
```

### AppColors Convention

```dart
// core/constants/app_colors.dart
// ALL colors live here. No color defined anywhere else.
abstract class AppColors {
  // Brand
  static const primary   = Color(0xFF1B4F8A);
  static const secondary = Color(0xFF2E7D6B);

  // Semantics
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57C00);
  static const error   = Color(0xFFD32F2F);
  static const info    = Color(0xFF0277BD);

  // Neutrals
  static const white      = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F6FA);
  static const surface    = Color(0xFFFFFFFF);
  static const divider    = Color(0xFFE0E0E0);

  // Text
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled  = Color(0xFFBDBDBD);
}
```

### AppSizes Convention

```dart
// core/constants/app_sizes.dart
abstract class AppSizes {
  // Spacing
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // Component heights
  static const double buttonHeight   = 48;
  static const double inputHeight    = 52;
  static const double appBarHeight   = 56;
  static const double drawerWidth    = 280;
}
```

### RTL Support

Arabic (`ar`) is supported from day one. All layout must respect text direction:

```dart
// ✅ Use Directionality-aware widgets
Row(children: [...])         // Flips automatically in RTL
EdgeInsetsDirectional.only() // Use instead of EdgeInsets.only for directional padding
TextAlign.start              // Use instead of TextAlign.left

// Context extension
context.isRTL  // true when locale is Arabic
```

---

## 7. Naming Conventions & Clean Code

### File & Folder Names → `snake_case`

```
vehicle_entity.dart         ✅
vehicleEntity.dart          ❌
VehicleEntity.dart          ❌
```

### Classes & Enums → `UpperCamelCase`

```dart
class VehicleRepositoryImpl  ✅
class vehicleRepositoryImpl  ❌

enum VehicleStatus           ✅
enum vehicleStatus           ❌
```

### Variables, Functions, Parameters → `lowerCamelCase`

```dart
final vehicleId = '123';     ✅
final VehicleId = '123';     ❌

void fetchVehicles() {}      ✅
void FetchVehicles() {}      ❌
```

### Constants → `lowerCamelCase` (NOT SCREAMING_SNAKE)

```dart
const defaultTimeout = 30;   ✅
const DEFAULT_TIMEOUT = 30;  ❌
```

### Booleans → affirmative predicates

```dart
bool isLoading  ✅    bool loading  ❌
bool hasError   ✅    bool error    ❌
bool canSubmit  ✅    bool submit   ❌
bool isVisible  ✅    bool visible  ❌
```

### Private members → prefix `_`

```dart
final String _token;
void _handleRefresh() {}
class _VehicleListViewState extends State<...> {}
```

### BLoC File Naming

| File | Suffix |
|------|--------|
| `vehicle_bloc.dart` | `Bloc` |
| `vehicle_event.dart` | `Event` |
| `vehicle_state.dart` | `State` |

### UseCase Naming → verb + noun + `UseCase`

```dart
GetVehiclesUseCase       ✅
TrackVehicleUseCase      ✅
AssignTaskUseCase        ✅
VehicleUseCase           ❌  (no verb)
GetVehicle               ❌  (no UseCase suffix)
```

### Clean Code Rules

| Rule | Hard Limit |
|------|-----------|
| Function length | 30 lines max |
| Nesting depth | 3 levels max |
| Widget `build()` length | 80 lines max — extract if larger |
| Class responsibility | One reason to change (SRP) |

```dart
// ✅ Guard clauses over nested ifs
Future<void> submit() async {
  if (!isValid) return;
  if (isLoading) return;
  // logic here at top level
}

// ❌ Nested ifs
Future<void> submit() async {
  if (isValid) {
    if (!isLoading) {
      // logic buried 2 levels deep
    }
  }
}
```

---

## 8. How to Add a New Feature

Follow these steps in order. Do not skip any.

### Step 1 — Copy the template

```bash
cp -r lib/features/_template lib/features/<feature_name>
```

Rename every file replacing `template` with your feature name:
```
template_entity.dart         → vehicle_entity.dart
template_model.dart          → vehicle_model.dart
template_repository.dart     → vehicle_repository.dart
# etc.
```

### Step 2 — Define the Entity (Domain)

In `domain/entities/<feature>_entity.dart`:
- Pure Dart class
- Annotate with `@freezed`
- Zero Flutter/Dio/DB imports
- Run: `dart run build_runner build --delete-conflicting-outputs`

### Step 3 — Define the Repository Interface (Domain)

In `domain/repositories/<feature>_repository.dart`:
- Abstract class only
- Return types: `Future<Either<Failure, T>>` for REST, `Stream<Either<Failure, T>>` for real-time
- No implementation here

### Step 4 — Define Use Cases (Domain)

One file per use case in `domain/usecases/`:
```dart
@injectable
class GetVehiclesUseCase {
  const GetVehiclesUseCase(this._repository);
  final VehicleRepository _repository;
  Future<Either<Failure, List<VehicleEntity>>> call() => _repository.getVehicles();
}
```

### Step 5 — Create the DTO Model (Data)

In `data/models/<feature>_model.dart`:
- Annotate with `@freezed`
- Add `fromJson` factory
- Use `@JsonKey(name: 'snake_case_key')` for API field mapping
- Run code generation

### Step 6 — Create the Mapper (Data)

In `data/mappers/<feature>_mapper.dart`:
- Pure top-level functions (no class needed)
- DTO → Entity only. Never Entity → DTO in domain direction.

### Step 7 — Create DataSources (Data)

`remote/<feature>_remote_datasource.dart`:
- Abstract interface + implementation
- Implementation annotated with `@Injectable(as: ...)`
- Returns DTOs — never entities
- Throws `AppException` — never returns `Either` (that's the repository's job)

### Step 8 — Implement the Repository (Data)

`repositories/<feature>_repository_impl.dart`:
- Annotate `@Injectable(as: <Feature>Repository)`
- `try/catch` every call
- Map every exception to the correct `Failure` subclass
- Return `Right(entity)` on success, `Left(failure)` on error

### Step 9 — Create BLoC (Presentation)

Three files: `bloc/`, `event/`, `state/`:
- State sealed with Freezed: `initial / loading / loaded / failure`
- Events: one per user action or system event
- BLoC annotated with `@injectable`
- Delegates all logic to use cases — no business logic in handlers

### Step 10 — Register in DI

Run code generation to auto-register:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Injectable auto-generates `injection_container.config.dart`. Verify your new classes appear.

### Step 11 — Add Route

In `core/router/app_routes.dart`:
```dart
static const vehicles = '/vehicles';
```

In `core/router/app_router.dart`:
```dart
GoRoute(
  path: AppRoutes.vehicles,
  builder: (context, state) => const VehicleListPage(),
),
```

### Step 12 — Add Localization Keys

In `core/localization/l10n/app_en.arb` and `app_ar.arb`:
```json
{
  "vehicles": "Vehicles",
  "vehiclesEmpty": "No vehicles found."
}
```

### Step 13 — Write Tests

Three test files minimum:
1. `domain/usecases/<feature>_usecase_test.dart` — happy path + every failure type
2. `data/repositories/<feature>_repository_impl_test.dart` — exception mapping
3. `presentation/bloc/<feature>_bloc_test.dart` — all state transitions

### Step 14 — Verify

```bash
flutter analyze          # zero issues
flutter test             # all tests pass
dart run build_runner build --delete-conflicting-outputs  # clean
```

---

## 9. Testing Strategy & Conventions

### Testing Pyramid

| Layer | % of Tests | Scope |
|-------|-----------|-------|
| Unit | 70% | UseCases, Repositories, Mappers, Validators, Services |
| Widget | 20% | Pages, reusable widgets, BLoC integration |
| Integration | 10% | Critical user flows end-to-end |

### Coverage Targets

| Layer | Target |
|-------|--------|
| Domain (entities, use cases) | 95%+ |
| Data (repositories, mappers) | 90%+ |
| Presentation (BLoC states) | 80%+ |
| Validators | 100% |
| Overall project | 80%+ |

### Naming Convention for Tests

```dart
// Pattern: should [expected outcome] when [condition]
'should return list of vehicles when repository succeeds'
'should return NetworkFailure when socket exception is thrown'
'should emit [loading, loaded] when GetVehiclesUseCase succeeds'
'should emit [loading, failure] when use case returns Left(AuthFailure)'
```

### UseCase Test Template

```dart
group('GetVehiclesUseCase', () {
  late MockVehicleRepository mockRepository;
  late GetVehiclesUseCase useCase;

  setUp(() {
    mockRepository = MockVehicleRepository();
    useCase = GetVehiclesUseCase(mockRepository);
  });

  test('should return list of vehicles when repository succeeds', () async {
    // Arrange
    final vehicles = [fakeVehicle];
    when(() => mockRepository.getVehicles())
        .thenAnswer((_) async => Right(vehicles));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(vehicles));
    verify(() => mockRepository.getVehicles()).called(1);
  });

  test('should return NetworkFailure when repository fails', () async {
    when(() => mockRepository.getVehicles())
        .thenAnswer((_) async => const Left(NetworkFailure(message: 'No internet')));

    final result = await useCase();

    expect(result, isA<Left<Failure, List<VehicleEntity>>>());
  });
});
```

### BLoC Test Template

```dart
blocTest<VehicleBloc, VehicleState>(
  'emits [loading, loaded] when started and use case succeeds',
  build: () {
    when(() => mockGetVehicles())
        .thenAnswer((_) async => Right([fakeVehicle]));
    return VehicleBloc(mockGetVehicles);
  },
  act: (bloc) => bloc.add(const VehicleEvent.started()),
  expect: () => [
    const VehicleState.loading(),
    VehicleState.loaded([fakeVehicle]),
  ],
);

blocTest<VehicleBloc, VehicleState>(
  'emits [loading, failure] when started and use case fails',
  build: () {
    when(() => mockGetVehicles())
        .thenAnswer((_) async => const Left(NetworkFailure(message: 'err')));
    return VehicleBloc(mockGetVehicles);
  },
  act: (bloc) => bloc.add(const VehicleEvent.started()),
  expect: () => [
    const VehicleState.loading(),
    const VehicleState.failure(NetworkFailure(message: 'err')),
  ],
);
```

### Error Path Test Matrix

Every feature repository test MUST cover:

| Scenario | Exception | Expected Failure |
|----------|-----------|-----------------|
| No internet | `SocketException` | `NetworkFailure` |
| Connection timeout | `DioExceptionType.connectionTimeout` | `NetworkFailure` |
| Request timeout | `DioExceptionType.receiveTimeout` | `TimeoutFailure` |
| Unauthorized | HTTP 401 | `AuthFailure` |
| Forbidden | HTTP 403 | `PermissionFailure` |
| Not found | HTTP 404 | `ServerFailure(code: '404')` |
| Validation error | HTTP 422 | `ValidationFailure` |
| Server crash | HTTP 500 | `ServerFailure` |
| Unknown | Any other | `UnknownFailure` |

### Mocking Rules

```dart
// ✅ Always mock
class MockVehicleRepository extends Mock implements VehicleRepository {}
class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

// Register fallback values for custom Freezed types
setUpAll(() {
  registerFallbackValue(fakeVehicle);
});

// ❌ Never mock
// Pure entities, value objects, simple DTOs, AppValidators
```

### Test File Location Rule

```
lib/features/vehicle/domain/usecases/get_vehicles_usecase.dart
test/features/vehicle/domain/usecases/get_vehicles_usecase_test.dart
```

Mirror the `lib/` structure exactly under `test/`.

### Pre-Commit Test Checklist

- [ ] All unit tests pass: `flutter test`
- [ ] Zero analyzer issues: `flutter analyze`
- [ ] Happy path tested
- [ ] Every `Failure` subclass path tested
- [ ] Edge cases: null, empty list, boundary values
- [ ] BLoC: initial → loading → success/failure sequence verified
- [ ] No magic values in tests — use named constants or `faker`
- [ ] No `print()` in test files — use `AppLogger` or test output

---

*This document must be updated whenever a new architectural decision is made,
a package is added/removed, or a convention is changed.*
*Treat it as living documentation — not a snapshot.*


### run flavors 
# Dev
flutter run --flavor dev --target lib/main_dev.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Prod
flutter run --flavor prod --target lib/main_prod.dart