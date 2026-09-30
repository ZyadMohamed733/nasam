import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/domain/entities/poi_draft.dart';
import 'package:nasam/features/poi/presentation/cubit/poi_editor_cubit.dart';
import 'package:nasam/features/poi/presentation/pages/poi_editor_page.dart';
import 'package:nasam/features/poi/presentation/widgets/poi_icon_picker.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_map_preview.dart';

import '../../helpers/poi_form_screens.dart';

void main() {
  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<AppButton>(find.byKey(AppFormBottomBar.primaryKey))
          .onPressed !=
      null;

  Finder field(Key key) =>
      find.descendant(of: find.byKey(key), matching: find.byType(EditableText));

  group('Edit', () {
    testWidgets('save is disabled, enables on a change, disables on revert', (
      tester,
    ) async {
      final cubit = await pumpPoiFormScreen(tester, PoiFormScreen.edit);
      final saved = cubit.state.point!;
      expect(find.text(saved.name), findsWidgets, reason: 'header and field');
      expect(saveEnabled(tester), isFalse);

      await tester.enterText(field(PoiFormLayout.nameKey), '${saved.name}!');
      await tester.pump();
      expect(saveEnabled(tester), isTrue);
      await tester.enterText(field(PoiFormLayout.nameKey), saved.name);
      await tester.pump();
      expect(saveEnabled(tester), isFalse, reason: 'reverted');

      // A coordinate typed differently but equal in value is no change.
      await tester.enterText(
        field(PoiFormLayout.latitudeKey),
        '${saved.latitude}0',
      );
      await tester.pump();
      expect(saveEnabled(tester), isFalse);
      await tester.enterText(field(PoiFormLayout.latitudeKey), '1');
      await tester.pump();
      expect(saveEnabled(tester), isTrue);
      await tester.enterText(
        field(PoiFormLayout.latitudeKey),
        '${saved.latitude}',
      );
      await tester.pump();
      expect(saveEnabled(tester), isFalse);

      // The icon, through the picker.
      final other = PoiIcon.values.firstWhere((i) => i != saved.icon);
      await tester.tap(find.byKey(PoiFormLayout.iconKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PoiIconPicker.rowKey(other)));
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isTrue);
      await tester.tap(find.byKey(PoiFormLayout.iconKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PoiIconPicker.rowKey(saved.icon)));
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('saving sends the edited draft', (tester) async {
      final cubit = await pumpPoiFormScreen(tester, PoiFormScreen.edit);
      await tester.enterText(field(PoiFormLayout.nameKey), 'Renamed');
      await tester.pump();
      final saved = cubit.stream.firstWhere(
        (state) => state.status == PoiEditorStatus.saved,
      );
      await tester.tap(find.byKey(AppFormBottomBar.primaryKey));
      expect((await saved).point?.name, 'Renamed');
      await tester.pumpAndSettle();
      // The page then pops back through GoRouter, which this harness does
      // not mount; the router tests cover the navigation.
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('Create', () {
    testWidgets('starts empty: placeholders, no pin, save enabled', (
      tester,
    ) async {
      await pumpPoiFormScreen(tester, PoiFormScreen.create);
      expect(find.text('إنشاء نقطة اهتمام جديدة'), findsOneWidget);
      expect(find.text('مثال : poi'), findsOneWidget);
      expect(find.text('اختيار الأيقونة'), findsOneWidget);
      expect(find.byType(AppMapPin), findsNothing);
      expect(saveEnabled(tester), isTrue);
      expect(find.text('هذا الحقل مطلوب'), findsNothing);
    });

    testWidgets('validates on submit, then the pin follows the coordinates', (
      tester,
    ) async {
      final cubit = await pumpPoiFormScreen(tester, PoiFormScreen.create);
      await tester.tap(find.byKey(AppFormBottomBar.primaryKey));
      await tester.pump();
      // Name and icon required; both coordinates invalid.
      expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));
      expect(find.text('أدخل إحداثيات صحيحة'), findsNWidgets(2));
      expect(cubit.state.status, isNot(PoiEditorStatus.saving));

      await tester.enterText(field(PoiFormLayout.latitudeKey), '24.695299');
      await tester.enterText(field(PoiFormLayout.longitudeKey), '46.672');
      await tester.pump();
      expect(find.byType(AppMapPin), findsOneWidget);
      expect(find.text('أدخل إحداثيات صحيحة'), findsNothing);
    });
  });
}
