import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/presentation/pages/poi_details_page.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon.dart';
import 'package:nasam/shared/widgets/app_info_section.dart';
import 'package:nasam/shared/widgets/app_map_preview.dart';
import 'package:nasam/shared/widgets/app_page_header.dart';

import '../../helpers/poi_form_screens.dart';

void main() {
  testWidgets('shows the point in four sections, coordinates in LTR at the '
      'Arabic start', (tester) async {
    final cubit = await pumpPoiFormScreen(tester, PoiFormScreen.view);
    final point = cubit.state.point!;
    final header = tester.widget<AppPageHeader>(find.byType(AppPageHeader));
    expect(header.title, point.name);
    expect(header.subtitle, 'تفاصيل نقاط الاهتمام');
    expect(find.byKey(PoiDetailsPage.editKey), findsOneWidget);
    expect(find.byType(AppMapPin), findsOneWidget);
    expect(find.byType(AppInfoSection), findsNWidgets(4));
    expect(find.byType(PoiIconImage), findsOneWidget);

    final latitude = tester.widget<Text>(
      find.text(point.latitude.toStringAsFixed(6)),
    );
    expect(latitude.textDirection, TextDirection.ltr);
    expect(latitude.textAlign, TextAlign.right);
    expect(find.text('حذف'), findsNothing, reason: 'no delete on View');
  });

  testWidgets('longitude and latitude stack on a narrow screen', (
    tester,
  ) async {
    await pumpPoiFormScreen(
      tester,
      PoiFormScreen.view,
      size: const Size(320, 568),
    );
    final longitude = tester.getRect(find.byKey(PoiViewLayout.longitudeKey));
    final latitude = tester.getRect(find.byKey(PoiViewLayout.latitudeKey));
    expect(latitude.top, greaterThan(longitude.bottom));
    expect(tester.takeException(), isNull);
  });
}
