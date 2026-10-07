import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// The alerts tab's own state, carried inside [AssetDetailsLoaded].
///
/// Separate from the details because it fails separately: an asset whose
/// alerts could not be fetched is not an asset with no alerts, and the tab has
/// to be able to say which, and to retry just itself.
sealed class AssetAlerts {
  const AssetAlerts();
}

final class AssetAlertsLoading extends AssetAlerts {
  const AssetAlertsLoading();

  @override
  bool operator ==(Object other) => other is AssetAlertsLoading;

  @override
  int get hashCode => (AssetAlertsLoading).hashCode;
}

final class AssetAlertsLoaded extends AssetAlerts {
  const AssetAlertsLoaded(this.notifications);
  final List<TrackedAssetNotification> notifications;

  @override
  bool operator ==(Object other) =>
      other is AssetAlertsLoaded &&
      listEquals(other.notifications, notifications);

  @override
  int get hashCode => Object.hashAll(notifications);
}

final class AssetAlertsFailed extends AssetAlerts {
  const AssetAlertsFailed(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is AssetAlertsFailed && other.failure == failure;

  @override
  int get hashCode => Object.hash(AssetAlertsFailed, failure);
}

/// What the five tabs share, loaded once for the screen.
final class AssetDetailsLoaded extends AssetDetailsState {
  const AssetDetailsLoaded({required this.details, required this.alerts});

  final TrackedAssetDetails details;
  final AssetAlerts alerts;

  AssetDetailsLoaded withAlerts(AssetAlerts alerts) =>
      AssetDetailsLoaded(details: details, alerts: alerts);

  @override
  bool operator ==(Object other) =>
      other is AssetDetailsLoaded &&
      identical(other.details, details) &&
      other.alerts == alerts;

  @override
  int get hashCode => Object.hash(details, alerts);
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
/// The details are what the screen is for, so their failing fails the screen.
/// The alerts are one tab of five: if only they fail, the other four stay
/// usable and the alerts tab reports the failure with its own retry, which
/// re-requests the alerts alone.
class AssetDetailsCubit extends Cubit<AssetDetailsState> {
  AssetDetailsCubit(this._getDetails, this._getNotifications)
    : super(const AssetDetailsLoading());

  final GetAssetDetailsUseCase _getDetails;
  final GetAssetNotificationsUseCase _getNotifications;

  /// The asset last asked for, so an alerts retry knows what to re-request.
  String? _assetId;

  Future<void> load(String assetId) async {
    _assetId = assetId;
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
        (d) =>
            AssetDetailsLoaded(details: d, alerts: _alertsFrom(notifications)),
      ),
    );
  }

  /// Re-requests the alerts only. The details already on screen stay put, and
  /// the other tabs never see a loading state.
  Future<void> retryAlerts() async {
    final assetId = _assetId;
    final current = state;
    if (assetId == null || current is! AssetDetailsLoaded) return;
    if (current.alerts is AssetAlertsLoading) return;

    emit(current.withAlerts(const AssetAlertsLoading()));
    final result = await _getNotifications(assetId);
    if (isClosed) return;

    final latest = state;
    if (latest is AssetDetailsLoaded) {
      emit(latest.withAlerts(_alertsFrom(result)));
    }
  }

  static AssetAlerts _alertsFrom(
    Either<Failure, List<TrackedAssetNotification>> result,
  ) => result.fold(
    AssetAlertsFailed.new,
    (list) => AssetAlertsLoaded(List.unmodifiable(list)),
  );
}
