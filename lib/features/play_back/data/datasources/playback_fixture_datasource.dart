import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/playback_point_model.dart';
import '../models/playback_segment_model.dart';
import 'playback_datasource.dart';
import 'playback_fixture_scenarios.dart';

/// Fixture implementation used until the playback API is available.
class PlaybackFixtureDataSource implements PlaybackDataSource {
  /// Choose list and map responses independently for device checks.
  /// See `docs/play_back.md` for supported values.
  static const String deviceSegmentsScenario = PlaybackFixtureScenarios.success;
  static const String deviceRouteScenario = PlaybackFixtureScenarios.success;

  PlaybackFixtureDataSource({
    AssetBundle? bundle,
    Duration? latency,
    bool? simulateFailure,
    String? scenario,
  }) : _bundle = bundle ?? rootBundle,
       _latency = latency ?? const Duration(milliseconds: 300),
       _segmentsScenario =
           scenario ??
           (simulateFailure == true
               ? PlaybackFixtureScenarios.serverError
               : simulateFailure == false
               ? PlaybackFixtureScenarios.success
               : _configuredSegmentsScenario),
       _routeScenario =
           scenario ??
           (simulateFailure == true
               ? PlaybackFixtureScenarios.serverError
               : simulateFailure == false
               ? PlaybackFixtureScenarios.success
               : _configuredRouteScenario);

  /// Release builds always use the regular fixture response.
  static const String _configuredSegmentsScenario = kDebugMode
      ? deviceSegmentsScenario
      : PlaybackFixtureScenarios.success;
  static const String _configuredRouteScenario = kDebugMode
      ? deviceRouteScenario
      : PlaybackFixtureScenarios.success;
  static const _root = 'assets/fixtures/play_back';
  static final _recordedDay = DateTime(2025, 10, 17);

  final AssetBundle _bundle;
  final Duration _latency;
  final String _segmentsScenario;
  final String _routeScenario;

  @override
  Future<List<PlaybackSegmentModel>> getSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    await _simulateResponse(_segmentsScenario);
    if (_segmentsScenario == PlaybackFixtureScenarios.empty ||
        _segmentsScenario == PlaybackFixtureScenarios.segmentsEmpty) {
      return const [];
    }
    final json =
        jsonDecode(
              _response(
                await _bundle.loadString('$_root/playback_segments.json'),
                scenario: _segmentsScenario,
              ),
            )
            as Map<String, dynamic>;
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

  @override
  Future<List<PlaybackPointModel>> getRoute({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    await _simulateResponse(_routeScenario);
    if (_routeScenario == PlaybackFixtureScenarios.empty ||
        _routeScenario == PlaybackFixtureScenarios.routeEmpty) {
      return const [];
    }

    print('_routeScenario: $_routeScenario');
    final json =
        jsonDecode(
              _response(
                await _bundle.loadString('$_root/playback_route.json'),
                scenario: _routeScenario,
              ),
            )
            as Map<String, dynamic>;
    final recorded = (json['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PlaybackPointModel.fromJson);
    return recorded
        .map(
          (point) => PlaybackPointModel(
            latitude: point.latitude,
            longitude: point.longitude,
            recordedAt: DateTime(
              from.year,
              from.month,
              from.day,
              point.recordedAt.hour,
              point.recordedAt.minute,
              point.recordedAt.second,
            ),
            headingDegrees: point.headingDegrees,
            speedKph: point.speedKph,
            distanceOdometerKm: point.distanceOdometerKm,
            isMoving: point.isMoving,
            engineOn: point.engineOn,
            locationEn: point.locationEn,
            locationAr: point.locationAr,
            fuelLevelPercent: point.fuelLevelPercent,
            humidityPercent: point.humidityPercent,
            temperatureCelsius: point.temperatureCelsius,
            weightKg: point.weightKg,
          ),
        )
        .where((p) => !p.recordedAt.isBefore(from) && p.recordedAt.isBefore(to))
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

  String _response(String response, {required String scenario}) =>
      scenario == PlaybackFixtureScenarios.malformedPayload
      ? '{ malformed playback response'
      : response;

  Future<void> _simulateResponse(String scenario) async {
    final delay = scenario == PlaybackFixtureScenarios.slow
        ? const Duration(seconds: 8)
        : _latency;
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    switch (scenario) {
      case PlaybackFixtureScenarios.success:
      case PlaybackFixtureScenarios.empty:
      case PlaybackFixtureScenarios.segmentsEmpty:
      case PlaybackFixtureScenarios.routeEmpty:
      case PlaybackFixtureScenarios.slow:
      case PlaybackFixtureScenarios.malformedPayload:
        return;
      case PlaybackFixtureScenarios.serverError:
        throw const ServerException(
          message: 'Simulated playback server error.',
          code: '503',
        );
      case PlaybackFixtureScenarios.networkError:
        throw const NetworkException(
          message: 'Simulated device offline.',
          code: 'offline',
        );
      case PlaybackFixtureScenarios.timeout:
        throw const TimeoutException(
          message: 'Simulated playback request timeout.',
          code: 'timeout',
        );
      case PlaybackFixtureScenarios.unauthorized:
        throw const AuthException(
          message: 'Simulated expired session.',
          code: '401',
        );
      case PlaybackFixtureScenarios.rateLimit:
        throw const RateLimitException(
          message: 'Simulated playback rate limit.',
          code: '429',
          retryAfterSeconds: 30,
        );
      case PlaybackFixtureScenarios.unknownError:
        throw StateError('Simulated unexpected playback data error.');
      default:
        throw ArgumentError.value(
          scenario,
          'scenario',
          'Unknown playback fixture scenario.',
        );
    }
  }
}
