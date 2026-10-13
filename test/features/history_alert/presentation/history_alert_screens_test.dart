import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/di/injection_container.dart';
import 'package:nasam/features/history_alert/data/datasources/history_alert_datasource.dart';
import 'package:nasam/features/history_alert/data/repositories/history_repo_impl.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_details_usecase.dart';
import 'package:nasam/features/history_alert/domain/usecase/get_history_usecase.dart';
import 'package:nasam/features/history_alert/presentation/cubit/alert_history_list_cubit.dart';
import 'package:nasam/features/history_alert/presentation/cubit/histroy_alert_cubit.dart';
import 'package:nasam/features/history_alert/presentation/pages/history_alert_details_page.dart';
import 'package:nasam/features/history_alert/presentation/pages/history_alert_page.dart';
import 'package:nasam/features/history_alert/presentation/widget/alert_history_filter_sheet.dart';
import 'package:nasam/features/history_alert/presentation/widget/applied_filter_chips.dart';
import 'package:nasam/features/history_alert/presentation/widget/history_alert_card.dart';
import 'package:nasam/features/history_alert/presentation/widget/search_bar_widget.dart';

import '../../../helpers/recording_adapter.dart';
import '../../../helpers/widget_harness.dart';
import '../alert_history_json.dart';

/// The real data source and repository over a recording transport, so the
/// screens are tested against contract-shaped responses.
late RecordingAdapter adapter;

HistoryRepoImpl repository() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
    ..httpClientAdapter = adapter;
  return HistoryRepoImpl(dataSource: HistoryAlertRemoteDataSource(dio));
}

Future<void> pumpList(WidgetTester tester) async {
  final repo = repository();
  getIt.registerFactory<AlertHistoryListCubit>(
    () => AlertHistoryListCubit(
      GetHistoryUseCase(repo),
      searchDebounce: Duration.zero,
    ),
  );
  addTearDown(() => getIt.unregister<AlertHistoryListCubit>());
  await pumpInApp(tester, const HistoryAlertPage(), locale: const Locale('ar'));
  await tester.pumpAndSettle();
}

Future<void> pumpDetails(
  WidgetTester tester,
  Map<String, dynamic> response, {
  int status = 200,
  Locale locale = const Locale('en'),
}) async {
  adapter.respond = (_) => (status, response);
  final repo = repository();
  final row = HistoryAlertEntity(
    id: 'a0000000-1',
    occurredAt: DateTime.utc(2026, 10, 13, 11, 47),
    asset: const AlertAsset(
      id: 'b',
      code: 'VH-001',
      name: LocalizedText(en: 'Truck 101', ar: 'شاحنة 101'),
    ),
    alertType: AlertType.speed,
    alertName: const LocalizedText(en: 'Speeding over 100 km/h', ar: 'سرعة'),
    triggeredValue: const LocalizedText(en: '108 km/h', ar: '108 كم/س'),
  );
  await pumpInApp(
    tester,
    BlocProvider(
      create: (_) =>
          HistoryAlertCubit(GetHistoryDetailsUseCase(repo))
            ..getHistoryAlertDetails(alertId: row.id),
      child: HistoryAlertDetailsPage(alert: row),
    ),
    locale: locale,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => adapter = RecordingAdapter((_) => (200, pageJson([]))));

  group('list', () {
    testWidgets('shows each alert in Arabic, coordinates or the no-location '
        'message', (tester) async {
      adapter.respond = (_) =>
          (200, pageJson([alertJson(), alertJson(id: 'two', location: null)]));
      await pumpList(tester);
      expect(find.byType(HistoryAlertCard), findsNWidgets(2));
      expect(find.text('تجاوز السرعة 100 كم/س'), findsNWidgets(2));
      expect(find.textContaining('شاحنة 101 - VH-001'), findsNWidgets(2));
      expect(find.textContaining('108 كم/س'), findsNWidgets(2));
      expect(find.textContaining('24.71360, 46.67530'), findsOneWidget);
      expect(
        find.textContaining('الموقع غير متاح لهذا التنبيه.'),
        findsOneWidget,
      );
    });

    testWidgets('no alerts at all shows the empty state', (tester) async {
      await pumpList(tester);
      expect(find.byType(HistoryAlertCard), findsNothing);
      expect(find.text('لا يوجد سجل تنبيهات متاح'), findsOneWidget);
      // Nothing was narrowed, so there is nothing to clear.
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('a search sends the keyword; clearing it reloads everything', (
      tester,
    ) async {
      await pumpList(tester);
      await tester.enterText(find.byType(TextField), 'Truck');
      await tester.pumpAndSettle();
      expect(adapter.requests.last.uri.queryParameters['search'], 'Truck');

      // No results for a narrowed list offers to clear it.
      final clear = find.byType(OutlinedButton);
      expect(clear, findsOneWidget);
      await tester.tap(clear);
      await tester.pumpAndSettle();
      expect(
        adapter.requests.last.uri.queryParameters.containsKey('search'),
        isFalse,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('scrolling to the end loads the next page', (tester) async {
      adapter.respond = (options) {
        final page = int.parse(options.uri.queryParameters['page']!);
        return (
          200,
          pageJson(
            [for (var i = 0; i < 20; i++) alertJson(id: 'p$page-$i')],
            page: page,
            totalPages: 2,
          ),
        );
      };
      await pumpList(tester);
      expect(adapter.requests, hasLength(1));
      await tester.drag(find.byType(ListView), const Offset(0, -6000));
      await tester.pumpAndSettle();
      expect(adapter.requests.map((r) => r.uri.queryParameters['page']), [
        '1',
        '2',
      ]);
    });

    testWidgets('a failed load can be retried', (tester) async {
      adapter.respond = (_) => (500, {'statusCode': 500});
      await pumpList(tester);
      expect(find.byType(HistoryAlertCard), findsNothing);
      adapter.respond = (_) => (200, pageJson([alertJson()]));
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryAlertCard), findsOneWidget);
    });

    testWidgets('applied filters show as chips with a count; a chip\'s × '
        'drops its filter and reloads', (tester) async {
      adapter.respond = (_) => (200, pageJson([alertJson()]));
      await pumpList(tester);
      expect(find.byKey(SearchBarWidget.badgeKey), findsNothing);

      await tester.tap(find.byKey(SearchBarWidget.filterButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(AlertHistoryFilterSheet.typeKey(AlertType.speed)),
      );
      await tester.tap(
        find.byKey(AlertHistoryFilterSheet.presetKey(AlertDatePreset.today)),
      );
      await tester.pump();
      await tester.tap(find.byKey(AlertHistoryFilterSheet.applyKey));
      await tester.pumpAndSettle();

      expect(adapter.requests.last.uri.queryParameters['alertType'], 'SPEED');
      expect(
        find.descendant(
          of: find.byKey(SearchBarWidget.badgeKey),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(AppliedFilterChips.typeKey), findsOneWidget);
      expect(find.byKey(AppliedFilterChips.dateKey), findsOneWidget);

      await tester.tap(find.byKey(AppliedFilterChips.typeKey));
      await tester.pumpAndSettle();
      final query = adapter.requests.last.uri.queryParameters;
      expect(query.containsKey('alertType'), isFalse);
      expect(query.containsKey('from'), isTrue);
      expect(find.byKey(AppliedFilterChips.typeKey), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(SearchBarWidget.badgeKey),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(AppliedFilterChips.dateKey));
      await tester.pumpAndSettle();
      expect(adapter.requests.last.uri.queryParameters.keys, ['page', 'limit']);
      expect(find.byKey(SearchBarWidget.badgeKey), findsNothing);
    });
  });

  group('details', () {
    testWidgets('speed: recorded speed and limit', (tester) async {
      await pumpDetails(tester, detailsJson(speedDetailsJson));
      expect(find.textContaining('108'), findsWidgets);
      expect(find.textContaining('100'), findsWidgets);
      expect(find.text('Truck 101 - VH-001'), findsOneWidget);
    });

    testWidgets('sensor: sensor, value and the configured condition', (
      tester,
    ) async {
      await pumpDetails(tester, detailsJson(sensorDetailsJson));
      expect(find.text('Sensor details'), findsOneWidget);
      expect(find.text('Truck 101 engine temperature'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('112 °C'), findsOneWidget);
      expect(find.textContaining('> 105 °C'), findsOneWidget);
    });

    testWidgets('downtime: the duration', (tester) async {
      await pumpDetails(tester, detailsJson(downtimeDetailsJson));
      expect(find.text('Downtime details'), findsOneWidget);
      expect(find.text('45 minutes'), findsOneWidget);
    });

    testWidgets('no location: the details still show, with the message', (
      tester,
    ) async {
      await pumpDetails(tester, detailsJson(speedDetailsJson, location: null));
      expect(
        find.text('Location is not available for this alert.'),
        findsOneWidget,
      );
      expect(find.text('Speeding over 100 km/h'), findsWidgets);
    });

    testWidgets('a missing alert shows the error with a retry', (tester) async {
      await pumpDetails(tester, {
        'statusCode': 404,
        'message': 'Alert not found',
      }, status: 404);
      // The row's name stays as the title while the error shows.
      expect(find.text('Speeding over 100 km/h'), findsOneWidget);
      expect(find.text('Sensor details'), findsNothing);
      adapter.respond = (_) => (200, detailsJson(downtimeDetailsJson));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Downtime details'), findsOneWidget);
    });
  });
}
