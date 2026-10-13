import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/data/datasources/fake_history_datasource.dart';
import 'package:nasam/features/history_alert/data/datasources/history_alert_fixture_scenarios.dart';
import 'package:nasam/features/history_alert/data/repositories/history_repo_impl.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/histroy_alert_cubit.dart';
import 'package:nasam/features/history_alert/presentation/cubit/hsitory_alert_state.dart';

import '../../../helpers/fixture_bundle.dart';

HistoryAlertCubit cubitFor(String scenario) {
  final repository = HistoryRepoImpl(
    dataSource: FakeHistoryDatasource(
      bundle: DiskAssetBundle(),
      latency: Duration.zero,
      scenario: scenario,
    ),
  );
  return HistoryAlertCubit(
    GetHistoryUseCase(repository),
    GetHistoryDetailsUseCase(repository),
  );
}

void main() {
  const speedOnly = AlertHistoryFilter(type: AlertType.speed);

  test('a loaded list starts unfiltered', () async {
    final cubit = cubitFor(HistoryAlertFixtureScenarios.success);
    addTearDown(cubit.close);
    await cubit.getHistoryAlertData();
    final state = cubit.state as HistoryAlertLoaded;
    expect(state.historyAlertDataList, isNotEmpty);
    expect(state.filter, AlertHistoryFilter.none);
  });

  test('applyFilter keeps the list and swaps the filter', () async {
    final cubit = cubitFor(HistoryAlertFixtureScenarios.success);
    addTearDown(cubit.close);
    await cubit.getHistoryAlertData();
    final alerts = (cubit.state as HistoryAlertLoaded).historyAlertDataList;

    cubit.applyFilter(speedOnly);
    expect(
      cubit.state,
      HistoryAlertLoaded(historyAlertDataList: alerts, filter: speedOnly),
    );

    // Reset.
    cubit.applyFilter(AlertHistoryFilter.none);
    expect(cubit.state, HistoryAlertLoaded(historyAlertDataList: alerts));
  });

  test('applyFilter is ignored until the list has loaded', () async {
    final cubit = cubitFor(HistoryAlertFixtureScenarios.serverError);
    addTearDown(cubit.close);
    await cubit.getHistoryAlertData();
    final failed = cubit.state;
    expect(failed, isA<HistoryAlertFailure>());
    cubit.applyFilter(speedOnly);
    expect(cubit.state, failed);
  });
}
