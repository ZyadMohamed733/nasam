import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_fixture_datasource.dart';
import 'package:nasam/features/tracking/data/repositories/tracking_repository_impl.dart';

/// Serves asset files from disk synchronously.
///
/// `rootBundle` reads through a platform channel with real IO, which cannot
/// complete inside a widget test's fake-async zone — and it caches the pending
/// future by key. A test that fails mid-load leaves that future in the cache,
/// and every later test in the file gets a load that never finishes: the
/// screen sits on its spinner and `pumpAndSettle` times out. Reading here
/// instead keeps widget tests off real IO entirely.
class DiskAssetBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) => SynchronousFuture(
    ByteData.sublistView(Uint8List.fromList(File(key).readAsBytesSync())),
  );

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

/// The tracking repository over the real JSON fixtures, with no latency and
/// no platform IO — what widget tests should build screens against.
TrackingRepositoryImpl fixtureTrackingRepository({bool fail = false}) =>
    TrackingRepositoryImpl(
      TrackingFixtureDataSource(
        bundle: DiskAssetBundle(),
        latency: Duration.zero,
        simulateFailure: fail,
      ),
    );
