import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_page.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/entities/history_details.dart';
import 'package:nasam/features/history_alert/domain/repositories/history_alert_repository.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/alert_history_list_cubit.dart';
import 'package:nasam/features/history_alert/presentation/cubit/alert_history_list_state.dart';

HistoryAlertEntity alert(String id) => HistoryAlertEntity(
  id: id,
  occurredAt: DateTime.utc(2026, 10, 13),
  asset: const AlertAsset(
    id: 'v',
    code: 'VH-001',
    name: LocalizedText(en: 'Truck', ar: 'شاحنة'),
  ),
  alertType: AlertType.speed,
  alertName: const LocalizedText(en: 'Speeding', ar: 'سرعة'),
  triggeredValue: const LocalizedText(en: '108 km/h', ar: '108 كم/س'),
);

/// Answers each query from [respond], recording what it was asked.
class ScriptedRepository implements HistoryAlertRepository {
  ScriptedRepository(this.respond);

  FutureOr<Either<Failure, AlertHistoryPage>> Function(AlertHistoryQuery)
  respond;
  final queries = <AlertHistoryQuery>[];

  @override
  Future<Either<Failure, AlertHistoryPage>> getHistoryAlert(
    AlertHistoryQuery query,
  ) async {
    queries.add(query);
    return respond(query);
  }

  @override
  Future<Either<Failure, HistoryAlertDetailsEntity>> getHistoryAlertDetails({
    required String alertId,
  }) => throw UnimplementedError();
}

/// Two pages of two alerts each.
Either<Failure, AlertHistoryPage> twoPages(AlertHistoryQuery query) => Right(
  AlertHistoryPage(
    alerts: [alert('${query.page}a'), alert('${query.page}b')],
    page: query.page,
    totalPages: 2,
    totalCount: 4,
  ),
);

const serverDown = ServerFailure(message: 'down', code: '503');

void main() {
  late ScriptedRepository repository;
  late AlertHistoryListCubit cubit;

  setUp(() {
    repository = ScriptedRepository(twoPages);
    cubit = AlertHistoryListCubit(
      GetHistoryUseCase(repository),
      searchDebounce: Duration.zero,
    );
  });
  tearDown(() => cubit.close());

  test('load shows loading, then the first page', () async {
    final states = <AlertHistoryListState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load();
    await pumpEventQueue();
    await sub.cancel();

    expect(states.first.status, AlertHistoryStatus.loading);
    expect(states.last.status, AlertHistoryStatus.loaded);
    expect(states.last.alerts.map((a) => a.id), ['1a', '1b']);
    expect(states.last.hasMore, isTrue);
    expect(repository.queries.single, const AlertHistoryQuery());
  });

  test('loadMore appends the next page, then stops at the last', () async {
    await cubit.load();
    await cubit.loadMore();
    expect(cubit.state.alerts.map((a) => a.id), ['1a', '1b', '2a', '2b']);
    expect(cubit.state.hasMore, isFalse);
    await cubit.loadMore();
    expect(repository.queries.map((q) => q.page), [1, 2]);
  });

  test('a failed next page keeps the list and offers a retry', () async {
    await cubit.load();
    repository.respond = (_) => const Left(serverDown);
    await cubit.loadMore();
    expect(cubit.state.status, AlertHistoryStatus.loaded);
    expect(cubit.state.alerts, hasLength(2));
    expect(cubit.state.loadMoreFailed, isTrue);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test('a failed first page is the failure state', () async {
    repository.respond = (_) => const Left(serverDown);
    await cubit.load();
    expect(cubit.state.status, AlertHistoryStatus.failure);
    expect(cubit.state.failure, serverDown);
    expect(cubit.state.alerts, isEmpty);
  });

  test('applying a filter reloads page one with it', () async {
    await cubit.load();
    await cubit.loadMore();
    const filter = AlertHistoryFilter(type: AlertType.sensor);
    await cubit.applyFilter(filter);
    expect(repository.queries.last, const AlertHistoryQuery(filter: filter));
    expect(cubit.state.filter, filter);
    expect(cubit.state.alerts.map((a) => a.id), ['1a', '1b']);
    expect(cubit.state.isNarrowed, isTrue);
  });

  test('Reset drops the filter and reloads', () async {
    await cubit.applyFilter(const AlertHistoryFilter(type: AlertType.sensor));
    await cubit.applyFilter(AlertHistoryFilter.none);
    expect(repository.queries.last, const AlertHistoryQuery());
    expect(cubit.state.isNarrowed, isFalse);
  });

  test('search reloads with the keyword once typing stops', () async {
    await cubit.load();
    cubit.onSearchChanged('Truck');
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();
    expect(repository.queries.last.search, 'Truck');
    expect(cubit.state.search, 'Truck');
    expect(cubit.state.isNarrowed, isTrue);
  });

  test('clearAll drops the filter and the search together', () async {
    await cubit.applyFilter(const AlertHistoryFilter(type: AlertType.speed));
    cubit.onSearchChanged('Truck');
    await pumpEventQueue();
    await cubit.clearAll();
    expect(repository.queries.last, const AlertHistoryQuery());
    expect(cubit.state.isNarrowed, isFalse);
  });

  test('an answer to an older request is dropped', () async {
    final slow = Completer<Either<Failure, AlertHistoryPage>>();
    repository.respond = (query) =>
        query.filter.type == null ? slow.future : twoPages(query);

    final first = cubit.load();
    await cubit.applyFilter(const AlertHistoryFilter(type: AlertType.speed));
    slow.complete(
      Right(
        AlertHistoryPage(
          alerts: [alert('stale')],
          page: 1,
          totalPages: 1,
          totalCount: 1,
        ),
      ),
    );
    await first;
    expect(cubit.state.alerts.map((a) => a.id), ['1a', '1b']);
  });

  test('refresh replaces the list without the loading state', () async {
    await cubit.load();
    repository.respond = (_) => Right(
      AlertHistoryPage(
        alerts: [alert('new'), alert('1a')],
        page: 1,
        totalPages: 1,
        totalCount: 2,
      ),
    );
    final states = <AlertHistoryListState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.refresh();
    await pumpEventQueue();
    await sub.cancel();
    expect(states.map((s) => s.status), [AlertHistoryStatus.loaded]);
    expect(cubit.state.alerts.first.id, 'new');
  });
}
