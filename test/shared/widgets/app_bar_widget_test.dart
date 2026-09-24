import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/constants/app_icons.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:nasam/shared/widgets/app_bar_widget.dart';

import '../../helpers/widget_harness.dart';

void main() {
  WebSocketService socket() => WebSocketService(
    const AppConfig(
      flavor: Flavor.dev,
      baseUrl: 'http://localhost',
      appName: 'Nasam',
      wsUrl: 'ws://localhost',
      tenant: 'test-tenant',
    ),
  );

  group('NasamAppBar', () {
    testWidgets('is the design height, not Material default', (tester) async {
      final bar = NasamAppBar(title: 'Home', wsService: socket());
      expect(bar.preferredSize.height, AppSizes.appBarHeight);

      await pumpInApp(tester, const SizedBox(), appBar: bar);
      expect(
        tester.getSize(find.byType(NasamAppBar)).height,
        AppSizes.appBarHeight,
      );
    });

    // The design's auth screens carry a back affordance and no title.
    testWidgets('renders without a title', (tester) async {
      await pumpInApp(
        tester,
        const SizedBox(),
        appBar: NasamAppBar(wsService: socket()),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(NasamAppBar), findsOneWidget);
    });

    testWidgets('centres the title when there is one', (tester) async {
      await pumpInApp(
        tester,
        const SizedBox(),
        appBar: NasamAppBar(title: 'Home', wsService: socket()),
      );

      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.centerTitle, isTrue);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('keeps the injected socket for the status dot', (tester) async {
      final ws = socket();
      await pumpInApp(
        tester,
        const SizedBox(),
        appBar: NasamAppBar(title: 'Home', wsService: ws),
      );

      expect(
        tester.widget<NasamAppBar>(find.byType(NasamAppBar)).wsService,
        same(ws),
      );
      expect(find.byType(StreamBuilder<WsConnectionState>), findsOneWidget);
    });

    testWidgets('draws the leading icon from the icon registry', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const SizedBox(),
        appBar: NasamAppBar(title: 'Home', wsService: socket()),
      );

      expect(find.byIcon(AppIcons.menu), findsOneWidget);
    });
  });
}
