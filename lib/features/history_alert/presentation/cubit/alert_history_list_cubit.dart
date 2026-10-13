import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alert_history_filter.dart';
import '../../domain/entities/alert_history_page.dart';
import '../../domain/usecase/get_history_usecase.dart';
import 'alert_history_list_state.dart';

/// Loads Alert History a page at a time, with the filter and the search
/// applied by the API.
///
/// Changing the filter or the search starts again from page one and shows
/// the loading state, so the old results are never presented as the new
/// ones (NASAM-621 scenario 31). A response that arrives after a newer
/// request has started is dropped.
class AlertHistoryListCubit extends Cubit<AlertHistoryListState> {
  AlertHistoryListCubit(
    this._getHistory, {
    this.pageSize = AlertHistoryQuery.defaultLimit,
    this.searchDebounce = const Duration(milliseconds: 400),
  }) : super(const AlertHistoryListState());

  final GetHistoryUseCase _getHistory;
  final int pageSize;

  /// How long the search field has to be quiet before the list reloads, so
  /// a typed word costs one request rather than one per letter.
  final Duration searchDebounce;

  Timer? _searchTimer;
  int _generation = 0;

  AlertHistoryQuery _query(int page) => AlertHistoryQuery(
    filter: state.filter,
    search: state.search,
    page: page,
    limit: pageSize,
  );

  /// Loads the first page for the current filter and search.
  Future<void> load() async {
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: AlertHistoryStatus.loading,
        alerts: const [],
        page: 0,
        hasMore: false,
        isLoadingMore: false,
        loadMoreFailed: false,
        failure: () => null,
      ),
    );
    await _fetchFirstPage(generation);
  }

  /// Fetches the first page again without clearing the list first — pull to
  /// refresh, where the indicator already shows the wait.
  Future<void> refresh() => _fetchFirstPage(++_generation);

  Future<void> _fetchFirstPage(int generation) async {
    final result = await _getHistory.getHistoryAlert(_query(1));
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AlertHistoryStatus.failure,
          alerts: const [],
          failure: () => failure,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: AlertHistoryStatus.loaded,
          alerts: page.alerts,
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
          loadMoreFailed: false,
          failure: () => null,
        ),
      ),
    );
  }

  /// Appends the next page. Does nothing while one is loading, when there
  /// is none, or before the first page has loaded.
  Future<void> loadMore() async {
    final current = state;
    if (current.status != AlertHistoryStatus.loaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final generation = _generation;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final result = await _getHistory.getHistoryAlert(_query(current.page + 1));
    if (isClosed || generation != _generation) return;
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true)),
      (page) => emit(
        state.copyWith(
          alerts: [...state.alerts, ...page.alerts],
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      ),
    );
  }

  /// Applies [filter] and reloads. [AlertHistoryFilter.none] is Reset.
  Future<void> applyFilter(AlertHistoryFilter filter) {
    emit(state.copyWith(filter: filter));
    return load();
  }

  /// Reloads with [query] once the user stops typing.
  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () {
      if (isClosed || query.trim() == state.search.trim()) return;
      emit(state.copyWith(search: query));
      load();
    });
  }

  /// Drops the filter and the search together and reloads.
  Future<void> clearAll() {
    _searchTimer?.cancel();
    emit(state.copyWith(filter: AlertHistoryFilter.none, search: ''));
    return load();
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
