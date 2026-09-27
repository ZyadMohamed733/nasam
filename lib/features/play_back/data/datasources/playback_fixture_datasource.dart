import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/playback_segment_model.dart';
import 'playback_datasource.dart';

/// Fixture implementation used until the playback API is available.
@LazySingleton(as: PlaybackDataSource)
class PlaybackFixtureDataSource implements PlaybackDataSource {
  PlaybackFixtureDataSource({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam Duration? latency,
    @ignoreParam bool? simulateFailure,
  }) : _bundle = bundle ?? rootBundle,
       _latency = latency ?? const Duration(milliseconds: 300),
       _simulateFailure = simulateFailure ?? _failureFlag;

  static const bool _failureFlag =
      kDebugMode && bool.fromEnvironment('TRACKING_FIXTURE_FAIL');
  static const _root = 'assets/fixtures/play_back';
  static final _recordedDay = DateTime(2025, 10, 17);

  final AssetBundle _bundle;
  final Duration _latency;
  final bool _simulateFailure;

  @override
  Future<List<PlaybackSegmentModel>> getSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    await _simulateNetwork();
    final json = jsonDecode(
      await _bundle.loadString('$_root/playback_segments.json'),
    ) as Map<String, dynamic>;
    final recorded = (json['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PlaybackSegmentModel.fromJson)
        .toList(growable: false);

    // This fixture records one day, so replay its legs on the requested day.
    return recorded
        .map((segment) => _onDay(segment, from))
        .where(
          (segment) =>
              !segment.startedAt.isBefore(from) && !segment.endedAt.isAfter(to),
        )
        .toList(growable: false);
  }

  PlaybackSegmentModel _onDay(PlaybackSegmentModel segment, DateTime day) {
    DateTime move(DateTime time) => DateTime(
      day.year,
      day.month,
      day.day + time.difference(_recordedDay).inDays,
      time.hour,
      time.minute,
      time.second,
    );

    return PlaybackSegmentModel(
      startedAt: move(segment.startedAt),
      endedAt: move(segment.endedAt),
      distanceKm: segment.distanceKm,
      durationMinutes: segment.durationMinutes,
      maxSpeedKph: segment.maxSpeedKph,
      startPlace: segment.startPlace,
      endPlace: segment.endPlace,
      status: segment.status,
    );
  }

  Future<void> _simulateNetwork() async {
    if (_latency > Duration.zero) await Future<void>.delayed(_latency);
    if (_simulateFailure) {
      throw const ServerException(
        message: 'Simulated tracking failure (TRACKING_FIXTURE_FAIL).',
        code: '503',
      );
    }
  }
}
