import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../../domain/usecases/get_tracked_assets_usecase.dart';
import '../../domain/usecases/get_tracking_vehicles_usecase.dart';
import 'tracking_state.dart';

export 'tracking_state.dart';

/// Owns the tracking screen's data, and the list's status filter and search.
///
/// Depends on use cases only. Created through `getIt` by the route, so the
/// widget tree receives it rather than building it — which is what lets a test
/// hand the screen a cubit in any state it likes.
@injectable
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._getVehicles, this._getAssets)
    : super(const TrackingInitial());

  final GetTrackingVehiclesUseCase _getVehicles;
  final GetTrackedAssetsUseCase _getAssets;

  /// How long the search field has to be quiet before the list narrows, so a
  /// typed word filters once rather than once per letter.
  static const searchDebounce = Duration(milliseconds: 300);

  Timer? _searchTimer;

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
        query: previous?.query ?? '',
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
  void onQueryChanged(String query) {
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
