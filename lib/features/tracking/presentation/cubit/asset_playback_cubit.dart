import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tracking_playback_segment.dart';
import '../../domain/usecases/get_playback_segments_usecase.dart';

sealed class AssetPlaybackState {
  const AssetPlaybackState();
}

final class AssetPlaybackLoading extends AssetPlaybackState {
  const AssetPlaybackLoading();

  @override
  bool operator ==(Object other) => other is AssetPlaybackLoading;

  @override
  int get hashCode => (AssetPlaybackLoading).hashCode;
}

final class AssetPlaybackLoaded extends AssetPlaybackState {
  const AssetPlaybackLoaded(this.segments);
  final List<TrackingPlaybackSegment> segments;

  @override
  bool operator ==(Object other) =>
      other is AssetPlaybackLoaded && listEquals(other.segments, segments);

  @override
  int get hashCode => Object.hashAll(segments);
}

final class AssetPlaybackFailure extends AssetPlaybackState {
  const AssetPlaybackFailure(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is AssetPlaybackFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(AssetPlaybackFailure, failure);
}

/// Loads an asset's journey legs for a date range.
///
/// The range is the page's — it owns the pickers — and it asks again whenever
/// the range changes. A request that finishes after a newer one was made is
/// dropped, so a slow answer for last week cannot overwrite today's.
@injectable
class AssetPlaybackCubit extends Cubit<AssetPlaybackState> {
  AssetPlaybackCubit(this._getSegments) : super(const AssetPlaybackLoading());

  final GetPlaybackSegmentsUseCase _getSegments;
  int _request = 0;

  /// Legs whose start and end fall inside [from, to).
  Future<void> load({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    final request = ++_request;
    emit(const AssetPlaybackLoading());

    final result = await _getSegments(assetId: assetId, from: from, to: to);
    if (isClosed || request != _request) return;

    emit(
      result.fold(
        AssetPlaybackFailure.new,
        (segments) => AssetPlaybackLoaded(List.unmodifiable(segments)),
      ),
    );
  }
}
