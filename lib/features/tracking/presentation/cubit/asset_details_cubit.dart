import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset_details.dart';
import '../../domain/usecases/get_asset_details_usecase.dart';
import '../../domain/usecases/get_asset_notifications_usecase.dart';

sealed class AssetDetailsState {
  const AssetDetailsState();
}

final class AssetDetailsLoading extends AssetDetailsState {
  const AssetDetailsLoading();

  @override
  bool operator ==(Object other) => other is AssetDetailsLoading;

  @override
  int get hashCode => (AssetDetailsLoading).hashCode;
}

/// What the five tabs share, loaded once for the screen.
final class AssetDetailsLoaded extends AssetDetailsState {
  const AssetDetailsLoaded({
    required this.details,
    required this.notifications,
  });

  final TrackedAssetDetails details;
  final List<TrackedAssetNotification> notifications;

  @override
  bool operator ==(Object other) =>
      other is AssetDetailsLoaded &&
      identical(other.details, details) &&
      listEquals(other.notifications, notifications);

  @override
  int get hashCode => Object.hash(details, Object.hashAll(notifications));
}

final class AssetDetailsFailure extends AssetDetailsState {
  const AssetDetailsFailure(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is AssetDetailsFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(AssetDetailsFailure, failure);
}

/// Loads an asset's details and its alerts for the details screen.
///
/// The details are what the screen is for, so they failing fails the screen.
/// The alerts are one tab of five: if only they fail, the other four still
/// render and the alerts tab shows its empty state — losing a whole screen to
/// a secondary list would be the worse outcome.
@injectable
class AssetDetailsCubit extends Cubit<AssetDetailsState> {
  AssetDetailsCubit(this._getDetails, this._getNotifications)
    : super(const AssetDetailsLoading());

  final GetAssetDetailsUseCase _getDetails;
  final GetAssetNotificationsUseCase _getNotifications;

  Future<void> load(String assetId) async {
    emit(const AssetDetailsLoading());

    final detailsRequest = _getDetails(assetId);
    final notificationsRequest = _getNotifications(assetId);
    await Future.wait([detailsRequest, notificationsRequest]);
    final details = await detailsRequest;
    final notifications = await notificationsRequest;
    if (isClosed) return;

    emit(
      details.fold(
        AssetDetailsFailure.new,
        (d) => AssetDetailsLoaded(
          details: d,
          notifications: List.unmodifiable(
            notifications.getOrElse(() => const []),
          ),
        ),
      ),
    );
  }
}
