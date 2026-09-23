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

  /// The asset a map marker stands for. Vehicle ids are numeric and assets are
  /// a shorter list, so the marker maps onto the fleet by position — a real
  /// backend would return the asset id on the vehicle and this goes away.
  TrackedAsset? assetForVehicle(TrackingVehicle vehicle) {
    if (assets.isEmpty) return null;
    final index = int.tryParse(vehicle.id);
    if (index == null) return null;
    return assets[(index - 1) % assets.length];
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
