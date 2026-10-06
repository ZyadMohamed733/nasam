import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/shared/widgets/route_progress.dart';

void main() {
  testWidgets('playback mode forwards slider changes', (tester) async {
    double? changedProgress;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: RouteProgress(
                  progress: .2,
                  onProgressChanged: (value) => changedProgress = value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);
    await expectLater(
      find.byType(RouteProgress),
      matchesGoldenFile('goldens/route_progress_playback.png'),
    );
    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pumpAndSettle();

    expect(changedProgress, isNotNull);
    expect(changedProgress, greaterThan(.2));
  });
}
