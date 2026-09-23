import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tracked_asset.dart';
import '../../domain/entities/tracking_vehicle.dart';
import '../../domain/repositories/tracking_repository.dart';

class TrackingState {
  const TrackingState({
    this.vehicles = const [],
    this.assets = const [],
    this.loading = true,
    this.failed = false,
  });

  final List<TrackingVehicle> vehicles;

  /// The fleet list behind the summary sheet, and what a map marker resolves
  /// to when it is tapped. Loaded alongside the vehicles because the screen
  /// shows both at once and two spinners for one screen is worse than one.
  final List<TrackedAsset> assets;

  final bool loading;
  final bool failed;

  int count(VehicleStatus status) =>
      vehicles.where((v) => v.status == status).length;

  /// The asset a tapped marker stands for, looked up by the id the vehicle
  /// carries. Returns null when the fleet has not loaded or the asset is not
  /// in the current list, which the caller treats as "do nothing".
  TrackedAsset? assetForVehicle(TrackingVehicle vehicle) {
    for (final asset in assets) {
      if (asset.id == vehicle.assetId) return asset;
    }
    return null;
  }
}

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._repository) : super(const TrackingState());

  final TrackingRepository _repository;

  Future<void> load() async {
    emit(const TrackingState());

    final vehicles = await _repository.getVehicles();
    final assets = await _repository.getTrackedAssets();
    if (isClosed) return;

    // Either side failing fails the screen: a map with no list, or a list with
    // no map, is not a state this screen has a design for.
    emit(
      vehicles.fold(
        (_) => const TrackingState(loading: false, failed: true),
        (v) => assets.fold(
          (_) => const TrackingState(loading: false, failed: true),
          (a) => TrackingState(
            vehicles: List.unmodifiable(v),
            assets: List.unmodifiable(a),
            loading: false,
          ),
        ),
      ),
    );
  }
}
