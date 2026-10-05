import '../../../../core/errors/failures.dart';
import '../../domain/entities/playback_point.dart';

sealed class PlaybackMapState {
  const PlaybackMapState();
}

final class PlaybackMapLoading extends PlaybackMapState {
  const PlaybackMapLoading();
}

final class PlaybackMapFailure extends PlaybackMapState {
  const PlaybackMapFailure(this.failure);
  final Failure failure;
}

final class PlaybackMapEmpty extends PlaybackMapState {
  const PlaybackMapEmpty();
}

final class PlaybackMapLoaded extends PlaybackMapState {
  const PlaybackMapLoaded({
    required this.points,
    this.currentIndex = 0,
    this.isPlaying = false,
    this.speed = 1,
  });

  final List<PlaybackPoint> points;
  final int currentIndex;
  final bool isPlaying;
  final double speed;

  PlaybackMapLoaded copyWith({int? currentIndex, bool? isPlaying}) =>
      PlaybackMapLoaded(
        points: points,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        speed: speed,
      );
}
