# Tracking home

The home route now hosts `TrackingPage`. `TrackingRepository` is registered in
`configureDependencies`; replace `DummyTrackingRepository` with the backend
implementation when ready. The fixture has 68 vehicles around Al Uyaynah, with
five compact groups and three isolated vehicles. Status counts use the same data.

`TrackingCubit` owns loading, failure and fleet state. `TrackingMap` fits the fleet
on creation, rasterizes the supplied arrow SVG into labeled status markers, and
uses `google_maps_cluster_manager` (the DanielSchmerber fork) to build
primary-colored count markers.
Clustering updates after camera movement and stops at zoom 17. Marker bitmaps are
cached per map/theme/locale; stale asynchronous renders are discarded.

Tapping a cluster animates the camera to its member vehicles, respecting the
bottom panel and leaving room for marker labels. The camera idle callback then
reclusters at the new zoom.

The hamburger opens the advanced drawer. Map gestures and drawer closing work.
Zoom in/out and the layers control (cycling normal, hybrid, terrain) are wired to
the map controller; the measurement and nearest-vehicle overlay tools were removed.
Status chips, Show, drawer search and destinations remain presentation only for this
phase. The profile is dummy data. Arabic and English use the existing localization
system; the drawer follows text direction.

## Native Maps setup

Set `GOOGLE_MAPS_API_KEY` in the root `.env` (already git-ignored), or supply the
environment variable in CI. Do not add `.env` to Flutter assets. Android reads the
value at Gradle configuration time. iOS generates a git-ignored
`ios/Flutter/MapsSecrets.xcconfig` during `pod install`. After changing the key,
run `ruby ios/maps_config.rb` before rebuilding from Xcode.

The iOS flavor files set their default entry point before including generated
Flutter settings, so explicit CLI targets (including integration tests) take precedence.

Android requires API 24+, iOS 14+. Maps SDK for Android and Maps SDK for iOS must
be enabled in the key's Google Cloud project. Restrict production keys to the
appropriate Android package/signing certificate or iOS bundle ID and APIs.
The key remains part of the native app binary; environment files protect source
control, not extraction from an installed app.

## Checks

```sh
flutter analyze
flutter test test/features/tracking test/core/constants/app_assets_test.dart
flutter test integration_test/tracking_test.dart -d emulator-5554 --flavor dev --dart-define-from-file=config/dev.json
```

The integration test launches the actual native map independently of authentication
and the backend, checks clustering, and opens the Arabic drawer.
