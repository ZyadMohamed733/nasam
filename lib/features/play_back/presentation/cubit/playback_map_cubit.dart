import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_playback_route_usecase.dart';
import 'playback_map_state.dart';
class PlaybackMapCubit extends Cubit<PlaybackMapState> {
  PlaybackMapCubit(this._getRoute) : super(const PlaybackMapLoading());
  final GetPlaybackRouteUseCase _getRoute;
  int _request = 0;
  Timer? _ticker;
  Future<void> load({
    required String assetId,
    required DateTime from,
    required DateTime to,
  }) async {
    final request = ++_request;
    _stopTicker();
    emit(const PlaybackMapLoading());
    final result = await _getRoute(assetId: assetId, from: from, to: to);
    if (isClosed || request != _request) return;
    result.fold(
      (failure) => emit(PlaybackMapFailure(failure)),
      (points) => points.isEmpty
          ? emit(const PlaybackMapEmpty())
          : emit(PlaybackMapLoaded(points: List.unmodifiable(points))),
    );
  }

  void toggle() {
    if (state is PlaybackMapLoaded && (state as PlaybackMapLoaded).isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    final current = state;
    if (current is! PlaybackMapLoaded ||
        current.currentIndex >= current.points.length - 1) {
      return;
    }
    _ticker?.cancel();
    emit(current.copyWith(isPlaying: true));
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final s = state;
      if (s is! PlaybackMapLoaded) return;
      if (s.currentIndex >= s.points.length - 1) {
        pause();
        return;
      }
      emit(s.copyWith(currentIndex: s.currentIndex + 1));
    });
  }

  void pause() {
    _stopTicker();
    final s = state;
    if (s is PlaybackMapLoaded && s.isPlaying) {
      emit(s.copyWith(isPlaying: false));
    }
  }

  void seek(int index) {
    final s = state;
    if (s is PlaybackMapLoaded) {
      pause();
      final latest = state as PlaybackMapLoaded;
      emit(
        latest.copyWith(currentIndex: index.clamp(0, latest.points.length - 1)),
      );
    }
  }

  void seekFraction(double fraction) {
    final s = state;
    if (s is PlaybackMapLoaded) {
      seek((fraction.clamp(0, 1) * (s.points.length - 1)).round());
    }
  }

  void next() {
    final s = state;
    if (s is PlaybackMapLoaded && s.currentIndex < s.points.length - 1) {
      seek(s.currentIndex + 1);
    }
  }

  void previous() {
    final s = state;
    if (s is PlaybackMapLoaded && s.currentIndex > 0) {
      seek(s.currentIndex - 1);
    }
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _stopTicker();
    return super.close();
  }
}
