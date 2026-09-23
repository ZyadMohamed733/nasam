import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/tracking_vehicle.dart';

class TrackingState {
  const TrackingState({
    this.vehicles = const [],
    this.loading = true,
    this.failed = false,
  });
  final List<TrackingVehicle> vehicles;
  final bool loading;
  final bool failed;
  int count(VehicleStatus status) =>
      vehicles.where((v) => v.status == status).length;
}

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this.repository) : super(const TrackingState());
  final TrackingRepository repository;
  Future<void> load() async {
    emit(const TrackingState());
    try {
      final vehicles = await repository.getVehicles();
      if (!isClosed) {
        emit(
          TrackingState(vehicles: List.unmodifiable(vehicles), loading: false),
        );
      }
    } catch (_) {
      if (!isClosed) emit(const TrackingState(loading: false, failed: true));
    }
  }
}
