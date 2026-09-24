import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/asset_details_model.dart';
import '../models/notification_model.dart';
import '../models/playback_segment_model.dart';
import '../models/tracked_asset_model.dart';
import '../models/vehicle_model.dart';
import 'tracking_datasource.dart';

/// Serves the tracking screens from JSON fixtures shaped like the API.
///
/// TODO(api): temporary until the tracking API is delivered. The contract
/// the real endpoints must meet is docs/api/tracking_contract.md, generated
/// from these fixtures by tool/tracking_contract.dart. Replace with a
/// Dio-backed `TrackingRemoteDataSource` carrying the same
/// `@LazySingleton(as: TrackingDataSource)` annotation and delete this class;
/// nothing above the data source changes. The fixtures under
/// `assets/fixtures/tracking/` are the working contract until then — each one
/// is a response in the `{ data: ... }` envelope the auth endpoints use, so
/// the models and mapper are exercised exactly as they will be against the
/// real service.
///
/// Bound in every flavor, deliberately: there is no backend yet, and a
/// flavor with no binding throws out of the container the moment a screen
/// resolves the repository.
///
/// Each call waits 300 ms by default so loading states are visible rather than
/// theoretical. Run with `--dart-define=TRACKING_FIXTURE_FAIL=true` to make
/// every call fail and walk the error states; the flag is ignored outside
/// debug builds, so a release can never ship failing on purpose.
@LazySingleton(as: TrackingDataSource)
class TrackingFixtureDataSource implements TrackingDataSource {
  TrackingFixtureDataSource({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam Duration? latency,
    @ignoreParam bool? simulateFailure,
  }) : _bundle = bundle ?? rootBundle,
       _latency = latency ?? const Duration(milliseconds: 300),
       _simulateFailure = simulateFailure ?? _failureFlag;

  static const bool _failureFlag =
      kDebugMode && bool.fromEnvironment('TRACKING_FIXTURE_FAIL');

  static const _root = 'assets/fixtures/tracking';

  /// The day the recorded playback legs were captured on.
  static final _playbackDay = DateTime(2025, 10, 17);

  final AssetBundle _bundle;
  final Duration _latency;
  final bool _simulateFailure;

  @override
  Future<List<VehicleModel>> getVehicles() async =>
      _list(await _response('vehicles.json'), VehicleModel.fromJson);

  @override
  Future<List<TrackedAssetModel>> getTrackedAssets() async =>
      _list(await _response('assets.json'), TrackedAssetModel.fromJson);

  @override
  Future<TrackedAssetModel> getTrackedAsset(String assetId) async {
    final assets = await getTrackedAssets();
    for (final asset in assets) {
      if (asset.id == assetId) return asset;
    }
    throw ServerException(message: 'No asset "$assetId".', code: '404');
  }

  @override
  Future<AssetDetailsModel> getAssetDetails(String assetId) async =>
      AssetDetailsModel.fromJson(
        await _responseFor('asset_details.json', assetId)
            as Map<String, dynamic>,
      );

  @override
  Future<List<NotificationModel>> getAssetNotifications(String assetId) async =>
      _list(
        await _responseFor('asset_notifications.json', assetId),
        NotificationModel.fromJson,
      );

  @override
  Future<List<PlaybackSegmentModel>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    final recorded = _list(
      await _response('playback_segments.json'),
      PlaybackSegmentModel.fromJson,
    );
    // The recording covers one day. A real service answers for whatever range
    // is asked, so the fixture replays that day's legs on the requested one —
    // same times of day, so a given range always yields the same legs and a
    // golden of the screen is stable.
    return recorded
        .map((s) => _onDay(s, from))
        .where((s) => !s.startedAt.isBefore(from) && !s.endedAt.isAfter(to))
        .toList(growable: false);
  }

  /// Reads a list-endpoint response and returns its `data`.
  Future<Object?> _response(String file) async {
    await _simulateNetwork();
    final json = await _read(file) as Map<String, dynamic>;
    return json['data'];
  }

  /// Reads a per-asset recording and returns that asset's `data`. A missing
  /// id is a 404, as the real endpoint would answer.
  Future<Object?> _responseFor(String file, String assetId) async {
    await _simulateNetwork();
    final recordings = await _read(file) as Map<String, dynamic>;
    final response = recordings[assetId] as Map<String, dynamic>?;
    if (response == null) {
      throw ServerException(message: 'No asset "$assetId".', code: '404');
    }
    return response['data'];
  }

  Future<Object?> _read(String file) async =>
      jsonDecode(await _bundle.loadString('$_root/$file'));

  Future<void> _simulateNetwork() async {
    if (_latency > Duration.zero) await Future<void>.delayed(_latency);
    if (_simulateFailure) {
      throw const ServerException(
        message: 'Simulated tracking failure (TRACKING_FIXTURE_FAIL).',
        code: '503',
      );
    }
  }

  static List<T> _list<T>(
    Object? data,
    T Function(Map<String, dynamic>) fromJson,
  ) => (data as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);

  static PlaybackSegmentModel _onDay(PlaybackSegmentModel s, DateTime day) {
    // Rebuilt from the date parts rather than shifted by a Duration: adding
    // days across a DST change moves the wall-clock time by an hour.
    DateTime moved(DateTime t) => DateTime(
      day.year,
      day.month,
      day.day + t.difference(_playbackDay).inDays,
      t.hour,
      t.minute,
      t.second,
    );
    return PlaybackSegmentModel(
      startedAt: moved(s.startedAt),
      endedAt: moved(s.endedAt),
      distanceKm: s.distanceKm,
      durationMinutes: s.durationMinutes,
      maxSpeedKph: s.maxSpeedKph,
      startPlace: s.startPlace,
      endPlace: s.endPlace,
    );
  }
}
