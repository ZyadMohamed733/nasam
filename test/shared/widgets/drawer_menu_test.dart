import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/localization/l10n/app_localizations.dart';
import 'package:nasam/shared/widgets/app_drawer.dart';
import 'package:nasam/shared/widgets/drawer_menu.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('foldForSearch', () {
    test('ignores case', () {
      expect(foldForSearch('Tracking Dashboard'), 'tracking dashboard');
    });

    test('treats Arabic letter variants and diacritics as the same', () {
      expect(foldForSearch('لوحة'), foldForSearch('لوحه'));
      expect(foldForSearch('الأسطول'), foldForSearch('الاسطول'));
      expect(foldForSearch('إعدادات'), foldForSearch('اعدادات'));
      expect(foldForSearch('مستوى'), foldForSearch('مستوي'));
      expect(foldForSearch('سِجِلّ'), foldForSearch('سجل'));
      expect(foldForSearch('ســجل'), foldForSearch('سجل'), reason: 'tatweel');
    });
  });

  group('filterDrawerMenu', () {
    final menu = appDrawerMenu(lookupAppLocalizations(const Locale('en')));

    List<String> labels(List<DrawerMenuSection> sections) => [
      for (final s in sections)
        for (final item in s.items)
          ...switch (item) {
            DrawerMenuGroup(:final label, :final entries) => [
              label,
              for (final e in entries) e.label,
            ],
            DrawerMenuEntry(:final label) => [label],
          },
    ];

    test('an empty query keeps the whole menu', () {
      expect(filterDrawerMenu(menu, '  '), same(menu));
    });

    test('an entry match keeps that entry under its group', () {
      expect(labels(filterDrawerMenu(menu, 'geo')), ['Fleet', 'Geofences']);
    });

    test('a group match keeps the whole group', () {
      expect(labels(filterDrawerMenu(menu, 'fleet')), [
        'Fleet',
        'Tracking dashboard',
        'Points of interest',
        'Geofences',
      ]);
    });

    test('matches across groups', () {
      expect(labels(filterDrawerMenu(menu, 'o')), contains('Alerts log'));
    });

    // Notifications are their own entry, not a child of Settings.
    test('the alerts log stands on its own, beside Settings', () {
      final settings = menu.last;
      expect(settings.items.whereType<DrawerMenuGroup>(), isEmpty);
      expect(
        [for (final e in settings.items.cast<DrawerMenuEntry>()) e.destination],
        [DrawerDestination.settings, DrawerDestination.alertsLog],
      );
    });

    test('a standalone entry matches on its own', () {
      expect(labels(filterDrawerMenu(menu, 'alert')), ['Alerts log']);
    });

    test('nothing matching leaves nothing', () {
      expect(filterDrawerMenu(menu, 'zzz'), isEmpty);
    });

    test('Arabic matches despite spelling variants', () {
      final ar = appDrawerMenu(lookupAppLocalizations(const Locale('ar')));
      // The ARB spells it "لوحة"; people type "لوحه".
      expect(
        labels(filterDrawerMenu(ar, 'لوحه')),
        contains(lookupAppLocalizations(const Locale('ar')).trackingTitle),
      );
    });
  });

  group('drawer', () {
    Future<void> pumpDrawer(WidgetTester tester, {Locale? locale}) async {
      await pumpInApp(
        tester,
        AppDrawer(
          onLogout: () {},
          selected: DrawerDestination.trackingDashboard,
          onSelect: (_) {},
        ),
        locale: locale ?? const Locale('en'),
      );
      await tester.pumpAndSettle();
    }

    Finder search() => find.descendant(
      of: find.byType(DrawerMenuSearchField),
      matching: find.byType(TextField),
    );

    testWidgets('matches the design: sections, groups, entries', (
      tester,
    ) async {
      await pumpDrawer(tester);
      for (final label in [
        'Systems',
        'Fleet',
        'Tracking dashboard',
        'Points of interest',
        'Geofences',
        'Settings',
        'Alerts log',
        'Logout',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      // Assignments is not in the design.
      expect(find.text('Assignments'), findsNothing);
    });

    testWidgets('a group collapses and expands', (tester) async {
      await pumpDrawer(tester);
      expect(find.text('Geofences'), findsOneWidget);
      Tristate expanded() =>
          tester.getSemantics(find.text('Fleet')).flagsCollection.isExpanded;
      expect(expanded(), Tristate.isTrue);

      await tester.tap(find.text('Fleet'));
      await tester.pumpAndSettle();
      expect(find.text('Geofences'), findsNothing);
      expect(find.text('Tracking dashboard'), findsNothing);
      expect(expanded(), Tristate.isFalse);
      // Nothing outside the group goes with it.
      expect(find.text('Alerts log'), findsOneWidget);
      expect(find.text('Settings'), findsNWidgets(2)); // section and entry

      await tester.tap(find.text('Fleet'));
      await tester.pumpAndSettle();
      expect(find.text('Geofences'), findsOneWidget);
    });

    testWidgets('the alerts log sits level with Settings, not under it', (
      tester,
    ) async {
      await pumpDrawer(tester);
      final settingsEntry = find.ancestor(
        of: find.text('Settings').last,
        matching: find.byType(InkWell),
      );
      final alertsLog = find.ancestor(
        of: find.text('Alerts log'),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getTopLeft(alertsLog.first).dx,
        tester.getTopLeft(settingsEntry.first).dx,
        reason: 'same indent: a sibling, not a child',
      );
      expect(
        tester.getTopLeft(find.text('Alerts log')).dy,
        greaterThan(tester.getTopLeft(find.text('Settings').last).dy),
      );
    });

    testWidgets('search filters the menu as you type', (tester) async {
      await pumpDrawer(tester);

      await tester.enterText(search(), 'geo');
      await tester.pump();

      expect(find.text('Geofences'), findsOneWidget);
      expect(find.text('Fleet'), findsOneWidget, reason: 'its group');
      expect(find.text('Tracking dashboard'), findsNothing);
      expect(find.text('Alerts log'), findsNothing);
      expect(find.text('Logout'), findsOneWidget, reason: 'not part of it');
    });

    testWidgets('search opens a collapsed group that has a match', (
      tester,
    ) async {
      await pumpDrawer(tester);
      await tester.tap(find.text('Fleet'));
      await tester.pumpAndSettle();
      expect(find.text('Geofences'), findsNothing);

      await tester.enterText(search(), 'geo');
      await tester.pumpAndSettle();
      expect(find.text('Geofences'), findsOneWidget);

      // Cleared, the user's choice comes back: Fleet was collapsed.
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Geofences'), findsNothing);
      expect(tester.widget<TextField>(search()).controller!.text, isEmpty);
    });

    testWidgets('no match says so', (tester) async {
      await pumpDrawer(tester);
      await tester.enterText(search(), 'zzz');
      await tester.pump();
      expect(find.text('No matching items'), findsOneWidget);
      expect(find.text('Fleet'), findsNothing);
    });

    testWidgets('Arabic search ignores letter variants', (tester) async {
      await pumpDrawer(tester, locale: const Locale('ar'));
      final l = lookupAppLocalizations(const Locale('ar'));

      await tester.enterText(search(), 'مناطق جغرافيه');
      await tester.pump();

      expect(find.text(l.trackingGeofences), findsOneWidget);
      expect(find.text(l.trackingTitle), findsNothing);
    });
  });
}
