import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/playback_segment.dart';

sealed class PlaybackState {
  const PlaybackState();
}

final class PlaybackLoading extends PlaybackState {
  const PlaybackLoading();

  @override
  bool operator ==(Object other) => other is PlaybackLoading;

  @override
  int get hashCode => runtimeType.hashCode;
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
