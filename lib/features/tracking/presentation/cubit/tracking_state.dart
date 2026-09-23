import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';

/// The tracking screen's states.
///
/// States are values: `blocTest` compares expected states with `==`, and a
/// state class without it compares by identity and can never match. Lists
/// compare element-wise; the elements are the entities the use cases returned,
/// passed through unchanged, so identity per element is what is being checked.
sealed class TrackingState {
  const TrackingState();

  /// The data the screen can show right now, whatever it is doing: the fleet
  /// itself when loaded, and the last loaded fleet while refreshing or after a
  /// failed refresh. Null only before the first successful load.
  TrackingLoaded? get visible => switch (this) {
    final TrackingLoaded s => s,
    TrackingLoading(:final previous) => previous,
    TrackingFailure(:final previous) => previous,
    TrackingInitial() || TrackingEmpty() => null,
  };
}

final class TrackingInitial extends TrackingState {
  const TrackingInitial();

  @override
  bool operator ==(Object other) => other is TrackingInitial;

  @override
  int get hashCode => (TrackingInitial).hashCode;
}

/// A load is in flight. [previous] is the fleet already on screen, so a
/// refresh repaints over it rather than blanking the map to a spinner.
final class TrackingLoading extends TrackingState {
  const TrackingLoading({this.previous});

  final TrackingLoaded? previous;

  @override
  bool operator ==(Object other) =>
      other is TrackingLoading && other.previous == previous;

  @override
  int get hashCode => Object.hash(TrackingLoading, previous);
}

final class TrackingLoaded extends TrackingState {
  const TrackingLoaded({
    required this.vehicles,
    required this.assets,
    this.filter,
    this.query = '',
  });

  final List<TrackingVehicle> vehicles;
  final List<TrackedAsset> assets;

  /// The status chip the list is narrowed to; null is "all".
  final VehicleStatus? filter;

  /// The committed (debounced) search text.
  final String query;

  /// The assets the list shows: [assets] narrowed by [filter] and [query].
  ///
  /// Derived rather than stored, so the full fleet is always there to count
  /// and to resolve a tapped marker against, whatever the list is showing.
  List<TrackedAsset> get visibleAssets {
    final needle = query.trim().toLowerCase();
    return assets
        .where((a) => filter == null || a.status == filter)
        .where(
          (a) =>
              needle.isEmpty ||
              a.name.toLowerCase().contains(needle) ||
              a.code.toLowerCase().contains(needle) ||
              a.assignedPerson.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  /// Vehicles in [status], for the chip counts.
  int count(VehicleStatus status) =>
      vehicles.where((v) => v.status == status).length;

  TrackedAsset? assetById(String id) {
    for (final asset in assets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  TrackingLoaded withFilter(VehicleStatus? filter) => TrackingLoaded(
    vehicles: vehicles,
    assets: assets,
    filter: filter,
    query: query,
  );

  TrackingLoaded withQuery(String query) => TrackingLoaded(
    vehicles: vehicles,
    assets: assets,
    filter: filter,
    query: query,
  );

  @override
  bool operator ==(Object other) =>
      other is TrackingLoaded &&
      listEquals(other.vehicles, vehicles) &&
      listEquals(other.assets, assets) &&
      other.filter == filter &&
      other.query == query;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(vehicles),
    Object.hashAll(assets),
    filter,
    query,
  );
}

/// The load succeeded and there is no fleet: no vehicles and no assets.
///
/// Distinct from a [TrackingLoaded] whose filter matches nothing — that is a
/// fleet the user has narrowed away, and it needs different copy and a way
/// back, not an empty state.
final class TrackingEmpty extends TrackingState {
  const TrackingEmpty();

  @override
  bool operator ==(Object other) => other is TrackingEmpty;

  @override
  int get hashCode => (TrackingEmpty).hashCode;
}

/// The load failed. [previous] is the last fleet that loaded, if any, so a
/// failed refresh keeps the map and the list on screen and only reports the
/// failure.
final class TrackingFailure extends TrackingState {
  const TrackingFailure(this.failure, {this.previous});

  final Failure failure;
  final TrackingLoaded? previous;

  @override
  bool operator ==(Object other) =>
      other is TrackingFailure &&
      other.failure == failure &&
      other.previous == previous;

  @override
  int get hashCode => Object.hash(TrackingFailure, failure, previous);
}
