# Nasam — Engineering Reference Guide

> **Version:** 1.1.0
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
4. [Flavor Architecture](#4-flavor-architecture)
5. [Code Patterns & Examples](#5-code-patterns--examples)
6. [Security Rules & Checklist](#6-security-rules--checklist)
7. [Responsive & UI Conventions](#7-responsive--ui-conventions)
8. [Naming Conventions & Clean Code](#8-naming-conventions--clean-code)
9. [How to Add a New Feature](#9-how-to-add-a-new-feature)
10. [Testing Strategy & Conventions](#10-testing-strategy--conventions)

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
| GetIt separation | BLoC and feature-scoped GetIt registration have distinct roles. Riverpod also acts as a DI container, creating architectural overlap. |
| Stream support | `on<Event>()` with `emit.forEach()` handles WebSocket streams natively and cleanly. |
| Team clarity | The Event → BLoC → State pattern is explicit and opinionated. Less "anything goes" ambiguity at team scale. |

### Dependency registration

GetIt registrations are written by feature under each feature's `di/` folder, with shared app wiring under `core/di/`. This keeps each feature's bindings readable and local while making missing registrations visible in the registration smoke test.

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
│   ├── main.dart                          # Shared init logic (initSharedLib). No runApp() here.
│   ├── main_dev.dart                      # Dev flavor entry point.
│   ├── main_staging.dart                  # Staging flavor entry point.
│   ├── main_prod.dart                     # Prod flavor entry point.
│   │
│   ├── app/
│   │   ├── app.dart                       # MaterialApp.router. ScreenUtil + l10n wired here.
│   │   ├── app_bloc_observer.dart         # Global BLoC lifecycle logger.
│   │   └── app_config.dart                # AppConfig singleton + Flavor enum. Set at startup.
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
│   │   │   ├── failures.dart              # Sealed Failure hierarchy (see Section 5).
│   │   │   └── exceptions.dart            # Internal AppException types (never exposed to UI).
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Dio singleton. baseUrl from AppConfig.baseUrl.
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
│   │   │   ├── validators.dart            # All form validators. See Section 5.
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
│   │       ├── app_scaffold.dart
│   │       ├── app_bar_widget.dart
│   │       ├── app_drawer.dart
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_card.dart
│   │       ├── app_dialog.dart
│   │       ├── app_bottom_sheet.dart
│   │       ├── app_snack_bar.dart
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── empty_state_widget.dart
│   │
│   └── features/
│       └── <feature_name>/
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── remote/
│           │   │   └── local/
│           │   ├── models/
│           │   ├── mappers/
│           │   └── repositories/
│           ├── domain/
│           │   ├── entities/
│           │   ├── repositories/
│           │   └── usecases/
│           └── presentation/
│               ├── bloc/
│               ├── pages/
│               └── widgets/
│
├── flavorizr.yaml                         # Flavor definitions (dev/staging/prod). See Section 4.
│
└── test/
    ├── helpers/
    │   ├── test_helper.dart
    │   └── mock_helper.dart
    ├── core/
    │   └── utils/validators_test.dart
    └── features/
        └── <feature_name>/
            ├── data/repositories/
            ├── domain/usecases/
            └── presentation/bloc/
```

### main.dart Initialization Order (strict — do not reorder)

```dart
// lib/main.dart — shared init, called by every flavor entry point
Future<void> initSharedLib() async {
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
}

// lib/main_dev.dart — dev flavor entry point
Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.dev,
    appName: AppConstants.devAppName,
    baseUrl: dotenv.env['DEV_BASE_URL'] ?? 'https://api-dev.nasam.app',
    wsUrl: dotenv.env['DEV_WS_URL'] ?? 'wss://ws-dev.nasam.app',
  );
  runApp(const NasamApp());
}
```

---

## 3. Packages & Dependencies

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | BLoC/Cubit state management |
| `bloc_concurrency` | ^0.3.0 | Event transformers: `droppable()`, `restartable()` for real-time events |
| `get_it` | ^9.2.1 | Service locator for app and feature dependency registration |
| `freezed_annotation` | ^3.1.0 | Immutable classes, sealed unions, copyWith, pattern matching |
| `json_annotation` | ^4.12.0 | JSON serialization annotations for DTOs |
| `dartz` | ^0.10.1 | `Either<Failure, T>` for typed functional error handling |
| `dio` | ^5.4.3 | HTTP client with interceptor pipeline |
| `connectivity_plus` | ^6.0.3 | Network connectivity detection |
| `web_socket_channel` | ^3.0.1 | WebSocket support for real-time vehicle tracking |
| `go_router` | ^13.2.0 | Declarative routing, deep links, auth guards, ShellRoute |
| `flutter_screenutil` | ^5.9.1 | Responsive scaling: `.w`, `.h`, `.r`, `.sp` |
| `flutter_secure_storage` | ^9.2.2 | Keychain (iOS) / Keystore (Android) for tokens |
| `flutter_dotenv` | ^5.1.0 | `.env` file loading — no hardcoded URLs or keys |
| `shared_preferences` | ^2.2.3 | Non-sensitive local storage (theme, locale preference) |
| `logger` | ^2.3.0 | Structured logging with levels. Replaces `print()` everywhere |
| `intl` | ^0.20.2 | Internationalization, date formatting, Arabic numeral support |
| `flutter_localizations` | SDK | Built-in localization delegates |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.9 | Code generation runner for Freezed and json_serializable |
| `freezed` | ^3.2.5 | Generator for Freezed annotations |
| `json_serializable` | ^6.8.0 | Generator for fromJson/toJson |
| `mocktail` | ^1.0.3 | Mock library for unit tests (no code-gen needed) |
| `bloc_test` | ^10.0.0 | `blocTest()` helper for testing BLoC state sequences |
| `faker` | ^2.1.0 | Realistic test data generation |
| `flutter_lints` | ^4.0.0 | Flutter-recommended lint rules |
| `flutter_flavorizr` | ^2.5.0 | CLI tool for generating flavor config (iOS xcconfig, schemes, Android Gradle). Dev-only. |

### Code Generation Command

Run after any change to annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Flavor Architecture

### Overview

Nasam uses **three flavors** to separate environments across the full development lifecycle. Each flavor is a completely independent app variant — different bundle ID, app name, and backend.

| Flavor | App Name | Android Application ID | iOS Bundle ID | Backend |
|--------|----------|------------------------|---------------|---------|
| `dev` | Nasam Dev | `com.nasam.app.dev` | `com.nasam.dev` | `https://api-dev.nasam.app` |
| `staging` | Nasam Staging | `com.nasam.app.staging` | `com.nasam.staging` | `https://api-stage.nasam.app` |
| `prod` | NASAM | `com.nasam.app` | `com.nasam.sts` | `https://api.nasam.app` |

All three flavors can be installed **simultaneously** on the same device — they have distinct bundle IDs.

---

### Tool: `flutter_flavorizr`

Flavor scaffolding is managed by [`flutter_flavorizr`](https://pub.dev/packages/flutter_flavorizr) (dev dependency only).

Configuration lives in **`flavorizr.yaml`** at the project root (not in `pubspec.yaml`):

```yaml
# flavorizr.yaml
flavors:
  dev:
    app:
      name: "Nasam Dev"
    android:
      applicationId: "com.nasam.app"
      generateDummyAssets: false
    ios:
      bundleId: "com.nasam.dev"
      generateDummyAssets: false

  staging:
    app:
      name: "Nasam Staging"
    android:
      applicationId: "com.nasam.app"
      generateDummyAssets: false
    ios:
      bundleId: "com.nasam.staging"
      generateDummyAssets: false

  prod:
    app:
      name: "NASAM"
    android:
      applicationId: "com.nasam.app"
      generateDummyAssets: false
    ios:
      bundleId: "com.nasam.sts"
      generateDummyAssets: false
```

> **Rule:** Never put the `flavorizr:` block inside `pubspec.yaml`. It belongs in `flavorizr.yaml` only.

---

### Dart Layer — AppConfig

`AppConfig` is a static singleton that holds the active flavor's runtime values. It is configured **once** at startup inside each flavor entry point, before `runApp()`.

```dart
// lib/app/app_config.dart
enum Flavor { dev, staging, prod }

class AppConfig {
  static late Flavor flavor;
  static late String baseUrl;
  static late String appName;
  static late String wsUrl;

  static void configure({
    required Flavor flavor,
    required String baseUrl,
    required String appName,
    required String wsUrl,
  }) {
    AppConfig.flavor = flavor;
    AppConfig.baseUrl = baseUrl;
    AppConfig.appName = appName;
    AppConfig.wsUrl = wsUrl;
  }

  static bool get isDev     => flavor == Flavor.dev;
  static bool get isStaging => flavor == Flavor.staging;
  static bool get isProd    => flavor == Flavor.prod;
}
```

**Usage anywhere in the app:**
```dart
// Read the active base URL (used by DioClient)
final baseUrl = AppConfig.baseUrl;

// Conditionally enable debug tools
if (AppConfig.isDev) {
  // show debug banner, extra logging, etc.
}
```

---

### Entry Points — One Per Flavor

Each flavor has its own `main_*.dart` entry point. The shared `lib/main.dart` contains only `initSharedLib()` — it has no `runApp()`.

```dart
// lib/main_dev.dart
Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.dev,
    appName: AppConstants.devAppName,
    baseUrl: dotenv.env['DEV_BASE_URL'] ?? 'https://api-dev.nasam.app',
    wsUrl: dotenv.env['DEV_WS_URL'] ?? 'wss://ws-dev.nasam.app',
  );
  runApp(const NasamApp());
}

// lib/main_staging.dart
Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.staging,
    appName: AppConstants.stageAppName,
    baseUrl: dotenv.env['STAGE_BASE_URL'] ?? 'https://api-stage.nasam.app',
    wsUrl: dotenv.env['STAGE_WS_URL'] ?? 'wss://ws-stage.nasam.app',
  );
  runApp(const NasamApp());
}

// lib/main_prod.dart
Future<void> main() async {
  await initSharedLib();
  AppConfig.configure(
    flavor: Flavor.prod,
    appName: AppConstants.appName,
    baseUrl: dotenv.env['PROD_BASE_URL'] ?? 'https://api.nasam.app',
    wsUrl: dotenv.env['PROD_WS_URL'] ?? 'wss://ws.nasam.app',
  );
  runApp(const NasamApp());
}
```

> **Rule:** Always pass `--target` alongside `--flavor`. Without it, Flutter defaults to `lib/main.dart` which has no `runApp()`.

---

### Environment Variables — `.env`

Base URLs and WebSocket URLs are loaded from `.env` at runtime via `flutter_dotenv`. The `.env` file is **gitignored** and never committed.

```env
# .env  ← never commit this file
DEV_BASE_URL=https://api-dev.nasam.app
DEV_WS_URL=wss://ws-dev.nasam.app

STAGE_BASE_URL=https://api-stage.nasam.app
STAGE_WS_URL=wss://ws-stage.nasam.app

PROD_BASE_URL=https://api.nasam.app
PROD_WS_URL=wss://ws.nasam.app

CONNECT_TIMEOUT_MS=15000
RECEIVE_TIMEOUT_MS=30000
```

> **Rule:** All `.env` keys accessed with `??` fallback — never with `!`. A missing key must never crash the app.

---

### Android Flavor Setup

Android flavors are configured **manually** in `android/app/build.gradle.kts` (not via flavorizr). Do not run flavorizr's Android processors.

```kotlin
flavorDimensions += "environment"

productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue(type = "string", name = "app_name", value = "Nasam Dev")
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".staging"
        versionNameSuffix = "-staging"
        resValue(type = "string", name = "app_name", value = "Nasam Staging")
    }
    create("prod") {
        dimension = "environment"
        resValue(type = "string", name = "app_name", value = "Nasam")
    }
}
```

`AndroidManifest.xml` uses `@string/app_name` (not hardcoded):
```xml
<application android:label="@string/app_name" ...>
```

---

### iOS Flavor Setup

iOS flavors are generated by `flutter_flavorizr`. The tool creates:

- `ios/Flutter/devDebug.xcconfig`, `devRelease.xcconfig`, `devProfile.xcconfig`
- `ios/Flutter/stagingDebug.xcconfig`, `stagingRelease.xcconfig`, `stagingProfile.xcconfig`
- `ios/Flutter/prodDebug.xcconfig`, `prodRelease.xcconfig`, `prodProfile.xcconfig`
- Build configurations per flavor in `Runner.xcodeproj/project.pbxproj`
- Schemes: `dev`, `staging`, `prod` in `Runner.xcodeproj/xcshareddata/xcschemes/`

Each xcconfig file must contain:
```
APP_NAME=Nasam Dev        # display name on home screen
FLUTTER_TARGET=lib/main_dev.dart  # correct Dart entry point
```

`ios/Runner/Info.plist` uses `$(APP_NAME)` for the display name:
```xml
<key>CFBundleDisplayName</key>
<string>$(APP_NAME)</string>
```

> **Known gotcha:** `flutter_flavorizr` sets `ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-$(ASSET_PREFIX)"` in the pbxproj. Since `generateDummyAssets: false` and no per-flavor icons are provided, `ASSET_PREFIX` is undefined → Xcode looks for `AppIcon-` → build fails. Fix: replace all `"AppIcon-$(ASSET_PREFIX)"` with `AppIcon` in `project.pbxproj`:
> ```bash
> sed -i '' 's/ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-$(ASSET_PREFIX)";/ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;/g' ios/Runner.xcodeproj/project.pbxproj
> ```

---

### Run Commands

```bash
# Dev
flutter run --flavor dev --target lib/main_dev.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Prod
flutter run --flavor prod --target lib/main_prod.dart
```

### Build Commands

```bash
# Android APK
flutter build apk --flavor dev --target lib/main_dev.dart
flutter build apk --flavor staging --target lib/main_staging.dart
flutter build apk --flavor prod --target lib/main_prod.dart --release --obfuscate --split-debug-info=build/debug-info

# iOS
flutter build ios --flavor dev --target lib/main_dev.dart
flutter build ios --flavor staging --target lib/main_staging.dart
flutter build ios --flavor prod --target lib/main_prod.dart --release
```

---

### Flavor Non-Negotiables

- ❌ **Never** run `flutter run` without `--flavor` and `--target` together
- ❌ **Never** hardcode base URLs — always read from `AppConfig.baseUrl`
- ❌ **Never** use `dotenv.env['KEY']!` — always use `??` fallback
- ❌ **Never** commit `.env` — it is gitignored
- ❌ **Never** put `flavorizr:` config inside `pubspec.yaml` — it lives in `flavorizr.yaml`
- ❌ **Never** run flavorizr's Android processors — Android is configured manually
- ✅ All three flavors can be installed simultaneously on the same device
- ✅ `AppConfig.isDev` / `isStaging` / `isProd` for conditional logic per flavor

---

## 5. Code Patterns & Examples

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

### Repository Implementation (Data)

```dart
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

### BLoC — Event, State, BLoC

```dart
// State
@freezed
class VehicleState with _$VehicleState {
  const factory VehicleState.initial()                             = _Initial;
  const factory VehicleState.loading()                             = _Loading;
  const factory VehicleState.loaded(List<VehicleEntity> vehicles) = _Loaded;
  const factory VehicleState.failure(Failure failure)             = _Failure;
}

// BLoC
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc(this._getVehicles) : super(const VehicleState.initial()) {
    on<_Started>(_onStarted);
  }

  final GetVehiclesUseCase _getVehicles;

  Future<void> _onStarted(_Started event, Emitter<VehicleState> emit) async {
    emit(const VehicleState.loading());
    final result = await _getVehicles();
    result.fold(
      (failure) => emit(VehicleState.failure(failure)),
      (vehicles) => emit(VehicleState.loaded(vehicles)),
    );
  }
}

// In the feature's DI function:
getIt.registerLazySingleton<VehicleRepository>(
  () => VehicleRepositoryImpl(getIt<VehicleRemoteDataSource>()),
);

// Register in the owning feature's dependencies function:
getIt.registerFactory<VehicleBloc>(
  () => VehicleBloc(getIt<GetVehiclesUseCase>()),
);
```

---

### Validators

```dart
class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? saudiPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^((\+966)|0)?5[0-9]{8}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid Saudi phone number';
    return null;
  }
}
```

---

### GoRouter Setup

```dart
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: RouteGuard.evaluate,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
    GoRoute(path: AppRoutes.login,  builder: (_, __) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(body: child),
      routes: [
        GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardPage()),
        GoRoute(path: AppRoutes.vehicles,  builder: (_, __) => const VehicleListPage()),
      ],
    ),
  ],
);
```

---

### WebSocket Service Pattern

```dart
enum WsConnectionState { connecting, connected, disconnected, error }

abstract class WebSocketService {
  Stream<dynamic> get messages;
  Stream<WsConnectionState> get connectionState;
  Future<void> connect(String url);
  void disconnect();
  void send(dynamic data);
}
// Implementation uses exponential backoff: 1s → 2s → 4s → max 30s
```

---

## 6. Security Rules & Checklist

### Token Storage — Rule

**All authentication tokens MUST be stored in `flutter_secure_storage`.**
Never use `SharedPreferences` for tokens. Never hardcode tokens anywhere.

```dart
// ✅ Correct
await secureStorage.write(key: 'access_token', value: token);

// ❌ Never
prefs.setString('token', token);
const token = 'eyJhbGci...';
```

### Environment Config — Rule

All URLs, API keys, timeouts, and WebSocket addresses live in `.env`.
`.env` is **always gitignored**. Never committed. Never hardcoded.

Access via:
```dart
dotenv.env['BASE_URL'] ?? ''   // ✅ always with fallback
dotenv.env['BASE_URL']!        // ❌ never force-unwrap
```

### Anti Reverse Engineering

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=.env
```

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

## 7. Responsive & UI Conventions

### Strategy

Nasam uses **one consistent design** across mobile and tablet.
`flutter_screenutil` scales all spacing, typography, and sizes proportionally.

**Design base size:** `375 × 812` (iPhone 13 portrait)

### ScreenUtil Usage

```dart
SizedBox(height: 16.h)
SizedBox(width: 24.w)
BorderRadius.circular(8.r)
TextStyle(fontSize: 14.sp)
```

### AppColors Convention

```dart
abstract class AppColors {
  static const primary   = Color(0xFF1B4F8A);
  static const secondary = Color(0xFF2E7D6B);
  static const success   = Color(0xFF2E7D32);
  static const warning   = Color(0xFFF57C00);
  static const error     = Color(0xFFD32F2F);
  static const info      = Color(0xFF0277BD);
  static const white     = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F6FA);
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
}
```

### AppSizes Convention

```dart
abstract class AppSizes {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double buttonHeight = 48;
  static const double inputHeight  = 52;
}
```

### RTL Support

```dart
// ✅ Directionality-aware
Row(children: [...])
EdgeInsetsDirectional.only()
TextAlign.start

// Context extension
context.isRTL  // true when locale is Arabic
```

---

## 8. Naming Conventions & Clean Code

| Subject | Convention | Example |
|---------|-----------|---------|
| Files & folders | `snake_case` | `vehicle_entity.dart` |
| Classes & enums | `UpperCamelCase` | `VehicleRepositoryImpl` |
| Variables & functions | `lowerCamelCase` | `fetchVehicles()` |
| Constants | `lowerCamelCase` | `defaultTimeout` |
| Booleans | affirmative prefix | `isLoading`, `hasError`, `canSubmit` |
| Private members | `_` prefix | `_token`, `_handleRefresh()` |
| UseCases | verb + noun + `UseCase` | `GetVehiclesUseCase` |

### Clean Code Rules

| Rule | Hard Limit |
|------|-----------|
| Function length | 30 lines max |
| Nesting depth | 3 levels max |
| Widget `build()` length | 80 lines max |

```dart
// ✅ Guard clauses
Future<void> submit() async {
  if (!isValid) return;
  if (isLoading) return;
  // logic here
}

// ❌ Nested ifs
Future<void> submit() async {
  if (isValid) {
    if (!isLoading) {
      // buried logic
    }
  }
}
```

---

## 9. How to Add a New Feature

The layer rules live in **[docs/FEATURE_CONVENTIONS.md](docs/FEATURE_CONVENTIONS.md)**,
and `lib/features/auth/` is the worked example — read both before starting. The
`_template` slice these steps used to say to copy has been deleted: auth is a real
feature that demonstrates the same rules, so the placeholder was one more thing to
keep in sync for no benefit.

Follow these steps in order. Do not skip any.

1. Create `lib/features/<feature_name>/` with `data/`, `domain/` and
   `presentation/`, modelled on `lib/features/auth/`
2. Define the **Entity** (Domain) — pure Dart, Freezed, zero Flutter imports
3. Define the **Repository Interface** (Domain) — abstract class, `Either` return types
4. Define **Use Cases** (Domain) — one file per use case, single `call()` method
5. Create the **DTO Model** (Data) — Freezed + json_serializable, `fromJson` factory
6. Create the **Mapper** (Data) — pure top-level functions, DTO → Entity only
7. Create **DataSources** (Data) — abstract interface + implementation registered in feature DI
8. Implement the **Repository** (Data) — `try/catch` every call, map to `Failure`
9. Create the **BLoC or Cubit** (Presentation) — a cubit where the screen calls one
   method per action, a bloc where events carry data worth logging or replaying;
   see the auth cubits and the shared `AuthFormStatus`
10. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
11. Add **Route** in `app_routes.dart` and `app_router.dart`
12. Add **Localization keys** to `app_ar.arb` first — it is the template, since
    Arabic is the source language — then the English in `app_en.arb`
13. Write **Tests** — usecase + repository + bloc (minimum 3 test files)
14. Verify: `flutter analyze` + `flutter test`

---

## 10. Testing Strategy & Conventions

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

### Pre-Commit Test Checklist

- [ ] All unit tests pass: `flutter test`
- [ ] Zero analyzer issues: `flutter analyze`
- [ ] Happy path tested
- [ ] Every `Failure` subclass path tested
- [ ] BLoC: initial → loading → success/failure sequence verified
- [ ] No `print()` in test files

---

*This document must be updated whenever a new architectural decision is made,
a package is added/removed, or a convention is changed.
Treat it as living documentation — not a snapshot.*
