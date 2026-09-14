# nasam

A new Flutter project.

## Running the app

There is no plain `lib/main.dart` entrypoint to run. Every launch picks a flavor,
and each flavor's API and socket URLs come from `config/<flavor>.json`:

```sh
flutter run --flavor dev     -t lib/main_dev.dart     --dart-define-from-file=config/dev.json
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json
flutter run --flavor prod    -t lib/main_prod.dart    --dart-define-from-file=config/prod.json
```

Those values are **compile-time** defines — `String.fromEnvironment` is const-folded
into the binary when it is built — so they cannot be supplied later and a hot restart
cannot add them. A launch that omits the flag fails at startup with
`Missing BASE_URL or WS_URL`, which is deliberate: the alternative is an app that
starts up pointing at nothing.

From an IDE, use the checked-in configurations rather than running an entrypoint
directly — running `lib/main_dev.dart` on its own is the usual cause of that error:

| Editor | Reads | Configurations |
|---|---|---|
| Android Studio / IntelliJ | `.run/*.run.xml` | `nasam dev`, `nasam staging`, `nasam prod` |
| VS Code | `.vscode/launch.json` | `nasam dev`, `nasam staging`, `nasam prod` |

Both folders are committed. `.idea/` is gitignored, so a run configuration created
through the Android Studio UI is stored where nobody else can see it — put new ones
in `.run/` instead.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
