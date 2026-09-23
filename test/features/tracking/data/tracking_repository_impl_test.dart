import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/data/datasources/tracking_dummy_datasource.dart';
import 'package:nasam/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset_details.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_playback_segment.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';

/// Throws the exception it is given, so the repository's translation of
/// exception into Failure can be checked without a network.
class _ThrowingDataSource implements TrackingDataSource {
  _ThrowingDataSource(this.error);
  final Object error;

  @override
  Future<List<TrackingVehicle>> getVehicles() async => throw error;
  @override
  Future<List<TrackedAsset>> getTrackedAssets() async => throw error;
  @override
  Future<TrackedAssetDetails> getAssetDetails(String assetId) async =>
      throw error;
  @override
  Future<List<TrackedAssetNotification>> getAssetNotifications(
    String assetId,
  ) async => throw error;
  @override
  Future<List<TrackingPlaybackSegment>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async => throw error;
}

void main() {
  group('TrackingRepositoryImpl', () {
    const repository = TrackingRepositoryImpl(TrackingDummyDataSource());

    test('every asset carries the id the routes will load it by', () async {
      final result = await repository.getTrackedAssets();
      final assets = result.getOrElse(() => const []);

      expect(assets, isNotEmpty);
      expect(assets.map((a) => a.id).toSet(), hasLength(assets.length));
      expect(assets.every((a) => a.id.isNotEmpty), isTrue);
    });

    test('details are stamped with the asset that was asked for', () async {
      final result = await repository.getAssetDetails('AST-0024');
      final details = result.getOrElse(
        () => throw StateError('no details'),
      );

      expect(details.assetId, 'AST-0024');
      // Identity fields are data now, not localisation keys.
      expect(details.name, isNotEmpty);
      expect(details.companyName, isNotEmpty);
      expect(details.address, isNotEmpty);
    });

    test('playback segments are anchored to the range, not to now', () async {
      final from = DateTime(2025, 3, 1);
      final a = await repository.getPlaybackSegments(
        assetId: 'AST-0017',
        from: from,
        to: from.add(const Duration(days: 1)),
      );
      final b = await repository.getPlaybackSegments(
        assetId: 'AST-0017',
        from: from,
        to: from.add(const Duration(days: 1)),
      );

      final first = a.getOrElse(() => const []);
      final second = b.getOrElse(() => const []);
      expect(first, isNotEmpty);
      expect(
        first.map((s) => s.startedAt),
        second.map((s) => s.startedAt),
        reason: 'the same range must yield the same legs, or goldens drift',
      );
    });

    test('an AppException becomes its matching Failure', () async {
      const source = ServerException(message: 'boom');
      final failing = TrackingRepositoryImpl(_ThrowingDataSource(source));

      final result = await failing.getTrackedAssets();

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });

    test('anything else becomes an UnknownFailure rather than escaping', () async {
      final failing = TrackingRepositoryImpl(
        _ThrowingDataSource(FormatException('bad shape')),
      );

      final result = await failing.getTrackedAssets();

      expect(result.fold((f) => f, (_) => null), isA<UnknownFailure>());
    });
  });
}
