import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracked_asset.dart';
import '../../domain/usecases/get_tracked_asset_usecase.dart';

sealed class TrackedAssetState {
  const TrackedAssetState();
}

final class TrackedAssetLoading extends TrackedAssetState {
  const TrackedAssetLoading();

  @override
  bool operator ==(Object other) => other is TrackedAssetLoading;

  @override
  int get hashCode => (TrackedAssetLoading).hashCode;
}

final class TrackedAssetLoaded extends TrackedAssetState {
  const TrackedAssetLoaded(this.asset);
  final TrackedAsset asset;

  @override
  bool operator ==(Object other) =>
      other is TrackedAssetLoaded && identical(other.asset, asset);

  @override
  int get hashCode => asset.hashCode;
}

/// No asset has this id — unknown, removed, or a malformed link. Distinct
/// from [TrackedAssetFailure] because retrying cannot help; the screen offers
/// a way home instead.
final class TrackedAssetNotFound extends TrackedAssetState {
  const TrackedAssetNotFound();

  @override
  bool operator ==(Object other) => other is TrackedAssetNotFound;

  @override
  int get hashCode => (TrackedAssetNotFound).hashCode;
}

final class TrackedAssetFailure extends TrackedAssetState {
  const TrackedAssetFailure(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is TrackedAssetFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(TrackedAssetFailure, failure);
}

/// Resolves the asset an id-only route points at.
///
/// The details and playback screens are reachable by link, which carries an
/// id and nothing else, so each screen resolves its own asset rather than
/// being handed one — and has to say something sensible when the id is wrong.
@injectable
class TrackedAssetCubit extends Cubit<TrackedAssetState> {
  TrackedAssetCubit(this._getAsset) : super(const TrackedAssetLoading());

  final GetTrackedAssetUseCase _getAsset;

  Future<void> load(String assetId) async {
    // A blank id cannot name an asset; there is nothing to ask the server.
    // Anything else goes to the server, which is the authority on what an id
    // looks like — the app guessing at a format would reject real ones.
    if (assetId.trim().isEmpty) {
      emit(const TrackedAssetNotFound());
      return;
    }

    emit(const TrackedAssetLoading());
    final result = await _getAsset(assetId);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => _isNotFound(failure)
            ? const TrackedAssetNotFound()
            : TrackedAssetFailure(failure),
        TrackedAssetLoaded.new,
      ),
    );
  }

  /// A 404 arrives as a ServerFailure with code '404' from both the real API
  /// (via the Dio exception mapper) and the fixture source.
  static bool _isNotFound(Failure failure) =>
      failure is ServerFailure && failure.code == '404';
}
