@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/history_alert/domain/entities/alert_history_filter.dart';
import 'package:nasam/features/history_alert/domain/entities/history_alert.dart';
import 'package:nasam/features/history_alert/presentation/widget/applied_filter_chips.dart';
import 'package:nasam/features/history_alert/presentation/widget/search_bar_widget.dart';

import '../../../helpers/widget_harness.dart';

/// The search row with two filters applied: the count badge and a chip per
/// filter ("Alert — Filter Applied", `988-17176`), across Arabic/English and
/// light/dark. Generated and compared on macOS only.
///
/// Written to `goldens/applied_filters/<language>_<theme>.png`.
void main() {
  final week = AlertHistoryFilter.rangeFor(
    AlertDatePreset.last7Days,
    DateTime.utc(2026, 10, 12, 22, 30),
  );
  final filter = AlertHistoryFilter(
    type: AlertType.speed,
    datePreset: AlertDatePreset.last7Days,
    from: week.from,
    to: week.to,
  );

  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      final file = '${language}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpInApp(
          tester,
          RepaintBoundary(
            key: const ValueKey('header'),
            child: SizedBox(
              width: 402,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchBarWidget(
                        controller: TextEditingController(),
                        onSearchChanged: (_) {},
                        onFilterPressed: () {},
                        filterCount: filter.activeCount,
                      ),
                      const SizedBox(height: 8),
                      AppliedFilterChips(filter: filter, onChanged: (_) {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
          locale: Locale(language),
          dark: dark,
        );
        await expectLater(
          find.byKey(const ValueKey('header')),
          matchesGoldenFile('goldens/applied_filters/$file.png'),
        );
      });
    }
  }
}
