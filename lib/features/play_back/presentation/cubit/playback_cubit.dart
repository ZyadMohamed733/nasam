import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/playback_segment.dart';
import '../../domain/usecases/get_playback_segments_usecase.dart';

sealed class PlaybackState {
  const PlaybackState();
}

final class PlaybackLoading extends PlaybackState {
  const PlaybackLoading();

  @override
  bool operator ==(Object other) => other is PlaybackLoading;

  @override
  int get hashCode => (PlaybackLoading).hashCode;
}

final class PlaybackLoaded extends PlaybackState {
  const PlaybackLoaded(this.segments);
  final List<PlaybackSegment> segments;

  @override
  bool operator ==(Object other) =>
      other is PlaybackLoaded && listEquals(other.segments, segments);

  @override
  int get hashCode => Object.hashAll(segments);
}

final class PlaybackFailure extends PlaybackState {
  const PlaybackFailure(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is PlaybackFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(PlaybackFailure, failure);
}

/// Loads an asset's journey legs for a date range.
///
/// The range is the page's — it owns the pickers — and it asks again whenever
/// the range changes. A request that finishes after a newer one was made is
/// dropped, so a slow answer for last week cannot overwrite today's.
@injectable
final class PlaybackCubit extends Cubit<PlaybackState> {
  PlaybackCubit(this._getSegments) : super(const PlaybackLoading());

  final GetPlaybackSegmentsUseCase _getSegments;
  int _request = 0;

  /// Legs whose start and end fall inside [from, to).
  Future<void> load({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    final request = ++_request;
    emit(const PlaybackLoading());

    final result = await _getSegments(assetId: assetId, from: from, to: to);
    if (isClosed || request != _request) return;

    emit(
      result.fold(
        PlaybackFailure.new,
        (segments) => PlaybackLoaded(List.unmodifiable(segments)),
      ),
    );
  }
}
