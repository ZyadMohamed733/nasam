import 'package:injectable/injectable.dart';

import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../../domain/entities/tracking_playback_segment.dart';
import '../../domain/entities/tracking_vehicle.dart';

abstract interface class TrackingDataSource {
  Future<List<TrackingVehicle>> getVehicles();
  Future<List<TrackedAsset>> getTrackedAssets();
  Future<TrackedAssetDetails> getAssetDetails(String assetId);
  Future<List<TrackedAssetNotification>> getAssetNotifications(String assetId);
  Future<List<TrackingPlaybackSegment>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  });
}

/// The one place sample tracking data lives.
///
/// It used to be three `dummy_data` files under `presentation/`, read directly
/// by a dozen widgets and by the core router. That put fixtures on the far side
/// of the architecture from the layer allowed to produce them, and meant the
/// screens could not be pointed at a real API without editing every one of
/// them. Everything above this class now talks to `TrackingRepository`, so the
/// swap is this binding.
///
/// Registered for the dev environment only. There is deliberately no
/// production binding: a prod build that reaches for tracking data should fail
/// loudly at resolution rather than quietly serve a fictional fleet.
@dev
@LazySingleton(as: TrackingDataSource)
class TrackingDummyDataSource implements TrackingDataSource {
  const TrackingDummyDataSource();

  @override
  Future<List<TrackingVehicle>> getVehicles() async {
    final vehicles = <TrackingVehicle>[];
    // Deterministic groups around Al Uyaynah, so the clusters are stable
    // between runs and a screenshot means something.
    const groups = [
      (24.925, 46.355, 15),
      (24.890, 46.410, 10),
      (24.845, 46.367, 5),
      (24.820, 46.397, 15),
      (24.791, 46.431, 20),
    ];
    for (final group in groups) {
      for (var i = 0; i < group.$3; i++) {
        vehicles.add(
          TrackingVehicle(
            id: '${vehicles.length + 1}',
            latitude: group.$1 + (i % 5) * .00015,
            longitude: group.$2 + (i ~/ 5) * .00015,
            status: VehicleStatus.values[i % 4],
            heading: (i % 8) * 45,
          ),
        );
      }
    }
    vehicles.addAll(const [
      TrackingVehicle(
        id: '66',
        latitude: 24.866,
        longitude: 46.401,
        status: VehicleStatus.stopped,
      ),
      TrackingVehicle(
        id: '67',
        latitude: 24.842,
        longitude: 46.443,
        status: VehicleStatus.moving,
      ),
      TrackingVehicle(
        id: '68',
        latitude: 24.805,
        longitude: 46.355,
        status: VehicleStatus.offline,
      ),
    ]);
    return List.unmodifiable(vehicles);
  }

  @override
  Future<List<TrackedAsset>> getTrackedAssets() async =>
      List.unmodifiable(_assets);

  @override
  Future<TrackedAssetDetails> getAssetDetails(String assetId) async =>
      _detailsFor(assetId);

  @override
  Future<List<TrackedAssetNotification>> getAssetNotifications(
    String assetId,
  ) async => List.unmodifiable(_notifications);

  @override
  Future<List<TrackingPlaybackSegment>> getPlaybackSegments({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Anchored to `from` rather than DateTime.now(), so the same range always
    // yields the same legs and a golden of this screen is stable.
    return List.unmodifiable(
      List<TrackingPlaybackSegment>.generate(6, (index) {
        final end = DateTime(
          from.year,
          from.month,
          from.day,
          18 - (index * 2),
        );
        final start = end.subtract(Duration(minutes: 30 + (index * 7)));
        return TrackingPlaybackSegment(
          startedAt: start,
          endedAt: end,
          distanceKm: 3.2 + index * .8,
          durationMinutes: 30 + index * 7,
          maxSpeedKph: 42 + index * 5,
          startPlace: index.isEven ? 'المطار' : 'موقف',
          endPlace: index.isEven ? 'موقف' : 'المطار',
        );
      }).where((s) => !s.startedAt.isBefore(from) && !s.endedAt.isAfter(to)),
    );
  }

  static const List<TrackedAsset> _assets = [
    TrackedAsset(
      id: 'AST-0017',
      name: 'الأصل ٢',
      code: 'AST-0017',
      status: VehicleStatus.moving,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .62,
    ),
    TrackedAsset(
      id: 'AST-0018',
      name: 'الأصل ٢',
      code: 'AST-0018',
      status: VehicleStatus.idle,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .38,
    ),
    TrackedAsset(
      id: 'AST-0019',
      name: 'الأصل ٢',
      code: 'AST-0019',
      status: VehicleStatus.stopped,
      assignedPerson: 'Aya Al-Rashidi',
      routeProgress: .18,
    ),
    TrackedAsset(
      id: 'AST-0021',
      name: 'الأصل ٣',
      code: 'AST-0021',
      status: VehicleStatus.moving,
      assignedPerson: 'Omar Hassan',
      routeProgress: .78,
    ),
    TrackedAsset(
      id: 'AST-0024',
      name: 'الأصل ٤',
      code: 'AST-0024',
      status: VehicleStatus.idle,
      assignedPerson: 'Mona Ali',
      routeProgress: .45,
    ),
    TrackedAsset(
      id: 'AST-0030',
      name: 'الأصل ٥',
      code: 'AST-0030',
      status: VehicleStatus.offline,
      assignedPerson: 'Khaled Nabil',
      routeProgress: .25,
    ),
    TrackedAsset(
      id: 'AST-0032',
      name: 'الأصل ٦',
      code: 'AST-0032',
      status: VehicleStatus.stopped,
      assignedPerson: 'Nour Samir',
      routeProgress: .12,
    ),
    TrackedAsset(
      id: 'AST-0040',
      name: 'الأصل ٧',
      code: 'AST-0040',
      status: VehicleStatus.offline,
      assignedPerson: 'Youssef Adel',
      routeProgress: .05,
    ),
  ];

  /// The sample detail record, stamped with whichever asset was asked for so
  /// the screen shows the id the route carried rather than a fixed one.
  static TrackedAssetDetails _detailsFor(String assetId) {
    final asset = _assets.firstWhere(
      (a) => a.id == assetId,
      orElse: () => _assets.first,
    );
    return TrackedAssetDetails(
      assetId: asset.code,
      name: asset.name,
      equipmentType: 'معدة',
      companyName: 'شركة نسام للتوزيع',
      managerName: 'أحمد محمد',
      address: 'طريق الملك فهد، الرياض، المملكة العربية السعودية',
      speedKph: 13,
      durationHours: 78,
      connectionMinutesAgo: 2,
      lastGpsAt: DateTime(2025, 10, 17, 9, 0),
      distanceKm: 125.48,
      fuelPercent: 96,
      idleHours: 26,
      tankLevelPercent: 74,
      temperatureCelsius: 26,
      weightKg: 2450,
      sensorCode: 'IO9',
      sensorBatteryMillivolts: 2625,
      sensorDistanceKm: 11752,
      fuelUsagePercent: 38,
      doorOpen: false,
      engineOn: true,
    );
  }

  static final List<TrackedAssetNotification> _notifications = [
    TrackedAssetNotification(
      type: TrackingNotificationType.speeding,
      date: DateTime(2025, 10, 17, 9, 0),
      speedKph: 13,
    ),
    TrackedAssetNotification(
      type: TrackingNotificationType.stopped,
      date: DateTime(2025, 10, 17, 8, 12),
      speedKph: 13,
    ),
    TrackedAssetNotification(
      type: TrackingNotificationType.geofence,
      date: DateTime(2025, 10, 17, 7, 36),
      speedKph: 13,
    ),
  ];
}
