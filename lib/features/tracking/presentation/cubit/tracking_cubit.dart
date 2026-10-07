import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../../domain/usecases/get_tracked_assets_usecase.dart';
import '../../domain/usecases/get_tracking_vehicles_usecase.dart';
import 'tracking_state.dart';

export 'tracking_state.dart';

/// Owns the tracking screen's data, and the list's status filter and search.
///
/// The status filter narrows the asset list only. The map always shows the
/// whole fleet, and the chip counts are counts of that whole fleet, so what the
/// chips say and what the map shows never disagree. Selecting a chip is a way
/// to read the list, not to hide vehicles from the map. This is a deliberate
/// product decision, not an omission — if it changes, filter the markers from
/// `TrackingLoaded.filter` in the page rather than dropping vehicles here.
///
/// Depends on use cases only. Created through `getIt` by the route, so the
/// widget tree receives it rather than building it — which is what lets a test
/// hand the screen a cubit in any state it likes.
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._getVehicles, this._getAssets)
    : super(const TrackingInitial());

  final GetTrackingVehiclesUseCase _getVehicles;
  final GetTrackedAssetsUseCase _getAssets;

  /// How long the search field has to be quiet before the list narrows, so a
  /// typed word filters once rather than once per letter.
  static const searchDebounce = Duration(milliseconds: 300);

  Timer? _searchTimer;

  /// The latest text typed, committed or not. A load that finishes while a
  /// search is still debouncing — or that ran while the user typed — lands on
  /// this rather than on the query of the fleet it replaced, so text typed
  /// during a load is not silently dropped.
  String? _pendingQuery;

  /// Loads, or refreshes, the fleet.
  ///
  /// Vehicles and assets are requested together, and either failing fails
  /// the load: a map with no list, or a list with no map, is not a state the
  /// screen has a design for. On a refresh the last loaded fleet rides along
  /// in [TrackingLoading] and [TrackingFailure], and a successful refresh
  /// keeps the filter and search the user had set.
  Future<void> load() async {
    if (state is TrackingLoading) return;
    final previous = state.visible;
    emit(TrackingLoading(previous: previous));

    // Both requests start before either is awaited.
    final vehiclesRequest = _getVehicles();
    final assetsRequest = _getAssets();
    await Future.wait([vehiclesRequest, assetsRequest]);
    final vehicles = await vehiclesRequest;
    final assets = await assetsRequest;
    if (isClosed) return;

    final failure = _failureOf(vehicles) ?? _failureOf(assets);
    if (failure != null) {
      emit(TrackingFailure(failure, previous: previous));
      return;
    }

    final loadedVehicles = List<TrackingVehicle>.unmodifiable(
      vehicles.getOrElse(() => const []),
    );
    final loadedAssets = List<TrackedAsset>.unmodifiable(
      assets.getOrElse(() => const []),
    );
    if (loadedVehicles.isEmpty && loadedAssets.isEmpty) {
      emit(const TrackingEmpty());
      return;
    }
    emit(
      TrackingLoaded(
        vehicles: loadedVehicles,
        assets: loadedAssets,
        filter: previous?.filter,
        query: _pendingQuery ?? previous?.query ?? '',
      ),
    );
  }

  /// Narrows the list to one status, or back to all of them with null.
  void setFilter(VehicleStatus? status) {
    final current = state;
    if (current is TrackingLoaded && current.filter != status) {
      emit(current.withFilter(status));
    }
  }

  /// Takes every keystroke, commits the text once typing pauses.
  ///
  /// The commit only applies to a loaded fleet. Text typed while loading is
  /// kept in [_pendingQuery] and applied when the load completes.
  void onQueryChanged(String query) {
    _pendingQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () {
      final current = state;
      if (!isClosed && current is TrackingLoaded && current.query != query) {
        emit(current.withQuery(query));
      }
    });
  }

  /// The asset a tapped map marker belongs to, by the id the vehicle carries.
  /// Null when nothing is loaded or the asset is not in the fleet, which the
  /// map treats as "do nothing".
  /// Drops the status filter and the search, typed or committed, at once.
  void clearFilters() {
    _searchTimer?.cancel();
    _pendingQuery = null;
    final current = state;
    if (current is TrackingLoaded &&
        (current.filter != null || current.query.isNotEmpty)) {
      emit(current.withFilter(null).withQuery(''));
    }
  }

  TrackedAsset? assetForVehicle(TrackingVehicle vehicle) =>
      state.visible?.assetById(vehicle.assetId);

  static Failure? _failureOf<T>(Either<Failure, T> result) =>
      result.fold((failure) => failure, (_) => null);

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
