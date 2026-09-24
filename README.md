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

## Golden tests

Screens and shared widgets have golden (pixel) tests under `test/goldens/`,
tagged `golden`. Text is rasterised differently on each OS, so the PNGs are
**generated and compared on macOS only** — the tests skip themselves on any
other platform, and a golden updated on Linux or Windows would fail for every
macOS developer.

```sh
flutter test --tags golden                   # compare
flutter test --tags golden --update-goldens  # regenerate (macOS only)
```

Regenerate after an intended visual change and review the PNG diffs before
committing them. The real fonts (Almarai and MaterialIcons) are registered
for every test by `test/flutter_test_config.dart`, so goldens show the actual
typeface and icons rather than the test font's boxes.

CI runs the goldens in a separate job on a macOS runner; the main Linux job
excludes the tag (`--exclude-tags golden`).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
