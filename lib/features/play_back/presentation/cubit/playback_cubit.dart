import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_playback_segments_usecase.dart';
import 'playback_state.dart';

/// Loads an asset's journey legs for a date range.
///
/// The range is the page's — it owns the pickers — and it asks again whenever
/// the range changes. A request that finishes after a newer one was made is
/// dropped, so a slow answer for last week cannot overwrite today's.
@injectable
final class PlaybackCubit extends Cubit<PlaybackState> {
  PlaybackCubit(this._getSegmentsUseCase) : super(const PlaybackLoading());

  final GetPlaybackSegmentsUseCase _getSegmentsUseCase;
  int _request = 0;

  /// Legs whose start and end fall inside [from, to).
  Future<void> load({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    final request = ++_request;
    emit(const PlaybackLoading());

    final result = await _getSegmentsUseCase(assetId: assetId, from: from, to: to);
    if (isClosed || request != _request) return;

    emit(
      result.fold(
        PlaybackFailure.new,
        (segments) => PlaybackLoaded(List.unmodifiable(segments)),
      ),
    );
  }
}
