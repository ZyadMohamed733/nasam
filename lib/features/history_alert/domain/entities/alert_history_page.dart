import 'alert_history_filter.dart';
import 'history_alert.dart';

/// What to ask Alert History for: the filter, the search keyword and the
/// page. The API sorts newest first by default, which is what the list wants.
class AlertHistoryQuery {
  const AlertHistoryQuery({
    this.filter = AlertHistoryFilter.none,
    this.search = '',
    this.page = 1,
    this.limit = defaultLimit,
  });

  static const int defaultLimit = 20;

  final AlertHistoryFilter filter;

  /// Matched by the API across vehicle, alert and sensor names, so it is
  /// also how the user narrows to one of those.
  final String search;
  final int page;
  final int limit;

  AlertHistoryQuery nextPage() => AlertHistoryQuery(
    filter: filter,
    search: search,
    page: page + 1,
    limit: limit,
  );

  @override
  bool operator ==(Object other) =>
      other is AlertHistoryQuery &&
      other.filter == filter &&
      other.search == search &&
      other.page == page &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(filter, search, page, limit);
}

/// One page of Alert History.
class AlertHistoryPage {
  const AlertHistoryPage({
    required this.alerts,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  final List<HistoryAlertEntity> alerts;
  final int page;
  final int totalPages;
  final int totalCount;

  bool get hasMore => page < totalPages;
}
