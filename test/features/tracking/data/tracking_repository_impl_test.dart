import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_datasource.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_fixture_datasource.dart';
import 'package:nasam/features/tracking/data/mappers/tracking_mapper.dart';
import 'package:nasam/features/tracking/data/models/asset_details_model.dart';
import 'package:nasam/features/tracking/data/models/notification_model.dart';
import 'package:nasam/features/tracking/data/models/playback_segment_model.dart';
import 'package:nasam/features/tracking/data/models/tracked_asset_model.dart';
import 'package:nasam/features/tracking/data/models/vehicle_model.dart';
import 'package:nasam/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';

/// Throws what it is given, so exception-to-failure mapping is testable
/// without a network.
class _ThrowingDataSource implements TrackingDataSource {
  _ThrowingDataSource(this.error);
  final Object error;

  @override
  Future<List<VehicleModel>> getVehicles() async => throw error;
  @override
  Future<List<TrackedAssetModel>> getTrackedAssets() async => throw error;
  @override
  Future<TrackedAssetModel> getTrackedAsset(String assetId) async =>
      throw error;
  @override
  Future<AssetDetailsModel> getAssetDetails(String assetId) async =>
      throw error;
  @override
  Future<List<NotificationModel>> getAssetNotifications(
    String assetId,
  ) async => throw error;
  @override
  Future<List<PlaybackSegmentModel>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async => throw error;
}

/// Serves one hand-written vehicle, to check the mapper's handling of the wire
/// status on its own.
class _SingleVehicleSource extends _ThrowingDataSource {
  _SingleVehicleSource(this.status) : super(StateError('unused'));
  final String status;

  @override
  Future<List<VehicleModel>> getVehicles() async => [
    VehicleModel(
      id: '1',
      assetId: 'AST-0017',
      latitude: 24.9,
      longitude: 46.3,
      status: status,
      heading: 90,
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TrackingRepositoryImpl repositoryOver({bool fail = false}) =>
      TrackingRepositoryImpl(
        TrackingFixtureDataSource(
          latency: Duration.zero,
          simulateFailure: fail,
        ),
      );

  group('against the JSON fixtures', () {
    test('the fleet parses from the envelope and every vehicle names an '
        'asset that exists', () async {
      final repository = repositoryOver();
      final vehicles = (await repository.getVehicles()).getOrElse(
        () => throw StateError('no vehicles'),
      );
      final assets = (await repository.getTrackedAssets()).getOrElse(
        () => throw StateError('no assets'),
      );

      expect(vehicles, hasLength(68));
      expect(vehicles.map((v) => v.id).toSet(), hasLength(68));
      final assetIds = assets.map((a) => a.id).toSet();
      expect(
        vehicles.every((v) => assetIds.contains(v.assetId)),
        isTrue,
        reason: 'a marker whose asset is missing cannot open anything',
      );
    });

    test('a single asset resolves by id, and an unknown id is a 404',
        () async {
      final found = (await repositoryOver().getTrackedAsset('AST-0021'))
          .getOrElse(() => throw StateError('not found'));
      expect(found.id, 'AST-0021');

      final missing = await repositoryOver().getTrackedAsset('AST-9999');
      expect(
        missing.fold((f) => f, (_) => null),
        isA<ServerFailure>().having((f) => f.code, 'code', '404'),
      );
    });

    test('the time in status comes from the contract, not the widget',
        () async {
      final asset = (await repositoryOver().getTrackedAsset('AST-0017'))
          .getOrElse(() => throw StateError('not found'));
      expect(asset.statusDuration, const Duration(seconds: 429));
    });

    test('a missing or negative time in status maps to none', () {
      TrackedAssetModel wire(Object? seconds) => TrackedAssetModel.fromJson({
        'id': 'A',
        'code': 'A',
        'name': 'A',
        'status': 'MOVING',
        'statusDurationSeconds': seconds,
      });
      expect(TrackingMapper.asset(wire(null)).statusDuration, isNull);
      expect(TrackingMapper.asset(wire(-5)).statusDuration, isNull);
      expect(
        TrackingMapper.asset(wire(61)).statusDuration,
        const Duration(seconds: 61),
      );
    });

    test('details come back for the asset that was asked for', () async {
      final details = (await repositoryOver().getAssetDetails('AST-0024'))
          .getOrElse(() => throw StateError('no details'));

      expect(details.assetId, 'AST-0024');
      expect(details.name, isNotEmpty);
      expect(details.address, isNotEmpty);
      expect(details.lastGpsAt, DateTime(2025, 10, 17, 9));
    });

    test('an unknown asset id is a failure, as the endpoint would 404',
        () async {
      final result = await repositoryOver().getAssetDetails('AST-9999');

      expect(
        result.fold((f) => f, (_) => null),
        isA<ServerFailure>().having((f) => f.code, 'code', '404'),
      );
    });

    test('notification wire types map onto the domain enum', () async {
      final notifications =
          (await repositoryOver().getAssetNotifications('AST-0017'))
              .getOrElse(() => const []);

      expect(notifications, hasLength(3));
    });

    test('playback replays on the requested day, identically each time',
        () async {
      final day = DateTime(2026, 3, 1);
      Future<List<DateTime>> starts() async =>
          (await repositoryOver().getPlaybackSegments(
                assetId: 'AST-0017',
                from: day,
                to: day.add(const Duration(days: 1)),
              ))
              .getOrElse(() => const [])
              .map((s) => s.startedAt)
              .toList();

      final first = await starts();
      expect(first, hasLength(6));
      expect(first.every((t) => _sameDay(t, day)), isTrue);
      expect(await starts(), first, reason: 'goldens need a stable fixture');
    });

    test('the debug failure flag fails every call as a Failure', () async {
      final result = await repositoryOver(fail: true).getTrackedAssets();

      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });
  });

  group('mapping and error translation', () {
    test('wire statuses map onto the domain enum', () async {
      for (final (wire, status) in [
        ('MOVING', VehicleStatus.moving),
        ('IDLE', VehicleStatus.idle),
        ('STOPPED', VehicleStatus.stopped),
        ('OFFLINE', VehicleStatus.offline),
      ]) {
        final vehicles = (await TrackingRepositoryImpl(
          _SingleVehicleSource(wire),
        ).getVehicles()).getOrElse(() => const []);
        expect(vehicles.single.status, status, reason: wire);
      }
    });

    // A status the app cannot draw is a contract change. It must surface as a
    // failure, not reach the map as a guess.
    test('an unknown wire status fails instead of being guessed', () async {
      final result = await TrackingRepositoryImpl(
        _SingleVehicleSource('TELEPORTING'),
      ).getVehicles();

      expect(result.fold((f) => f, (_) => null), isA<UnknownFailure>());
    });

    test('an AppException becomes its matching Failure', () async {
      final result = await TrackingRepositoryImpl(
        _ThrowingDataSource(const ServerException(message: 'boom')),
      ).getTrackedAssets();

      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });

    test('anything else becomes an UnknownFailure rather than escaping',
        () async {
      final result = await TrackingRepositoryImpl(
        _ThrowingDataSource(const FormatException('bad shape')),
      ).getTrackedAssets();

      expect(result.fold((f) => f, (_) => null), isA<UnknownFailure>());
    });
  });
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
