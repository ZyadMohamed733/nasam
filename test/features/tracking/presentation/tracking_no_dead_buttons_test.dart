import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nasam/features/tracking/presentation/widgets/tracking_summary.dart';

import '../../../helpers/asset_screens.dart';
import '../../../helpers/fake_map_platform.dart';
import '../../../helpers/inert_controls.dart';
import '../../../helpers/tracking_screen.dart';

/// Every control a user can activate on the tracking screen must do
/// something they can observe; see [findInertControls].
void main() {
  for (final drawerOpen in [false, true]) {
    testWidgets(
      'no enabled control is a no-op, drawer ${drawerOpen ? 'open' : 'closed'}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final nav = recordingRouter();
        late FakeMapPlatform platform;

        final inert = await findInertControls(
          tester,
          fresh: () async {
            platform = FakeMapPlatform(createsMap: true);
            await tester.pumpWidget(const SizedBox());
            await pumpTrackingScreen(
              tester,
              size: const Size(402, 874),
              platform: platform,
              wrap: (screen) =>
                  InheritedGoRouter(goRouter: nav.router, child: screen),
            );
            await tester.tap(
              find.descendant(
                of: find.byType(TrackingSummary),
                matching: find.text('Show'),
              ),
            );
            await tester.pumpAndSettle();
            if (drawerOpen) {
              tester
                  .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
                  .controller!
                  .showDrawer();
              await tester.pumpAndSettle();
            }
            platform.cameraMoves.clear();
          },
          state: () => [
            nav.log.length,
            platform.cameraMoves.length,
            tester.widget<GoogleMap>(find.byType(GoogleMap)).mapType,
            tester
                .widget<AdvancedDrawer>(find.byType(AdvancedDrawer))
                .controller!
                .value
                .visible,
          ],
        );

        expect(inert, isEmpty, reason: 'enabled controls that did nothing');
        semantics.dispose();
      },
    );
  }
}
