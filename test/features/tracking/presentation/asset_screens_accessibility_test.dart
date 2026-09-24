import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';

import '../../../helpers/asset_screens.dart';
import '../../../helpers/inert_controls.dart';

Future<void> _meetsAllGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

List<String> _tabs(AppLocalizations l) => [
  l.assetDetailsInformation,
  l.assetDetailsTracking,
  l.assetDetailsLocation,
  l.assetDetailsAssets,
  l.assetDetailsNotifications,
];

/// Opens details tab [index] of a freshly built screen.
Future<void> _openTab(WidgetTester tester, int index) async {
  final label = _tabs(lookupAppLocalizations(const Locale('en')))[index];
  final tab = find.widgetWithText(Tab, label);
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  const en = Locale('en');
  final tabNames = _tabs(lookupAppLocalizations(en));

  group('guidelines', () {
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      for (var tab = 0; tab < tabNames.length; tab++) {
        testWidgets('details, ${tabNames[tab]} tab, $theme', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpScreen(tester, assetDetailsScreen(), dark: dark);
          await _openTab(tester, tab);
          await _meetsAllGuidelines(tester);
          semantics.dispose();
        });
      }

      testWidgets('playback, $theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpScreen(
          tester,
          assetPlaybackScreen(),
          router: recordingRouter().router,
          dark: dark,
        );
        await _meetsAllGuidelines(tester);
        semantics.dispose();
      });
    }
  });

  group('no inert controls', () {
    for (var tab = 0; tab < tabNames.length; tab++) {
      testWidgets('details, ${tabNames[tab]} tab', (tester) async {
        final semantics = tester.ensureSemantics();
        final nav = recordingRouter();
        final inert = await findInertControls(
          tester,
          fresh: () async {
            await tester.pumpWidget(const SizedBox());
            await pumpScreen(tester, assetDetailsScreen(), router: nav.router);
            await _openTab(tester, tab);
          },
          state: () => [nav.log.length],
        );
        expect(inert, isEmpty, reason: 'enabled controls that did nothing');
        semantics.dispose();
      });
    }

    testWidgets('playback', (tester) async {
      final semantics = tester.ensureSemantics();
      final nav = recordingRouter();
      final inert = await findInertControls(
        tester,
        fresh: () async {
          await tester.pumpWidget(const SizedBox());
          await pumpScreen(tester, assetPlaybackScreen(), router: nav.router);
        },
        state: () => [nav.log.length],
      );
      expect(inert, isEmpty, reason: 'enabled controls that did nothing');
      semantics.dispose();
    });
  });
}
