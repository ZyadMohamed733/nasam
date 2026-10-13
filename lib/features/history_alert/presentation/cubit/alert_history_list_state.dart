import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/alert_history_filter.dart';
import '../../domain/entities/history_alert.dart';

enum AlertHistoryStatus { loading, loaded, failure }

/// The Alert History list: what is shown, what it was asked for, and how far
/// through the pages it is.
///
/// One state class rather than one per status, because the filter and the
/// search outlive every status: the search field must keep its text while
/// the list reloads under it.
@immutable
class AlertHistoryListState {
  const AlertHistoryListState({
    this.status = AlertHistoryStatus.loading,
    this.alerts = const [],
    this.filter = AlertHistoryFilter.none,
    this.search = '',
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.failure,
  });

  final AlertHistoryStatus status;
  final List<HistoryAlertEntity> alerts;
  final AlertHistoryFilter filter;
  final String search;

  /// The last page loaded; 0 before the first.
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  /// Why the first page failed. Null unless [status] is failure.
  final Failure? failure;

  /// Whether the user narrowed the list, which decides between the "no
  /// alerts" and the "no results" empty states.
  bool get isNarrowed => filter.isActive || search.trim().isNotEmpty;

  AlertHistoryListState copyWith({
    AlertHistoryStatus? status,
    List<HistoryAlertEntity>? alerts,
    AlertHistoryFilter? filter,
    String? search,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    Failure? Function()? failure,
  }) => AlertHistoryListState(
    status: status ?? this.status,
    alerts: alerts ?? this.alerts,
    filter: filter ?? this.filter,
    search: search ?? this.search,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    failure: failure == null ? this.failure : failure(),
  );

  @override
  bool operator ==(Object other) =>
      other is AlertHistoryListState &&
      other.status == status &&
      listEquals(other.alerts, alerts) &&
      other.filter == filter &&
      other.search == search &&
      other.page == page &&
      other.hasMore == hasMore &&
      other.isLoadingMore == isLoadingMore &&
      other.loadMoreFailed == loadMoreFailed &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(
    status,
    Object.hashAll(alerts),
    filter,
    search,
    page,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
    failure,
  );
}
