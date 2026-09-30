import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_dashed_box.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_form_card.dart';
import 'package:nasam/shared/widgets/app_form_field.dart';
import 'package:nasam/shared/widgets/app_info_section.dart';
import 'package:nasam/shared/widgets/app_map_preview.dart';
import 'package:nasam/shared/widgets/app_outline_icon_button.dart';
import 'package:nasam/shared/widgets/app_page_header.dart';
import 'package:nasam/shared/widgets/hit_target.dart';

import '../../helpers/widget_harness.dart';

void main() {
  Matcher about(double value) => moreOrLessEquals(value, epsilon: .5);

  group('AppPageHeader', () {
    for (final (locale, rtl) in [
      (const Locale('ar'), true),
      (const Locale('en'), false),
    ]) {
      testWidgets('${locale.languageCode}: 71 tall, chevron at the start', (
        tester,
      ) async {
        var backs = 0;
        await pumpInApp(
          tester,
          Align(
            alignment: Alignment.topCenter,
            child: AppPageHeader(
              title: 'Title',
              subtitle: 'Subtitle',
              onBack: () => backs++,
              trailing: HitTargetExtender(
                child: AppOutlineIconButton(
                  tooltip: 'Edit',
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 24),
                ),
              ),
            ),
          ),
          locale: locale,
        );
        final header = tester.getRect(find.byType(AppPageHeader));
        expect(header.height, about(71));
        final back = tester.getRect(find.byKey(AppPageHeader.backKey));
        expect(back.size, const Size(24, 24));
        expect(back.top - header.top, about(12));
        expect(
          rtl ? header.right - back.right : back.left - header.left,
          about(16),
        );
        final edit = tester.getRect(find.byType(AppOutlineIconButton));
        expect(edit.size, const Size(44, 44));
        expect(
          rtl ? edit.left - header.left : header.right - edit.right,
          about(16),
        );
        final title = tester.widget<Text>(find.text('Title'));
        expect(title.style?.fontSize, 18);
        expect(title.style?.color, AppColors.gray900);
        expect(tester.widget<Text>(find.text('Subtitle')).style?.fontSize, 14);

        // The 24 chevron answers across 48.
        await tester.tapAt(back.center.translate(rtl ? 20 : -20, 20));
        expect(backs, 1);
      });
    }
  });

  testWidgets(
    'AppFormField: label, 8, a 44 input; value style is a parameter',
    (tester) async {
      final controller = TextEditingController(text: '24.695299');
      addTearDown(controller.dispose);
      const input = ValueKey('input');
      await pumpInApp(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppFormField(
            label: 'Latitude',
            isRequired: true,
            controller: controller,
            inputKey: input,
            valueStyle: const TextStyle(fontSize: 12, height: 20 / 12),
          ),
        ),
      );
      final label = tester.getRect(find.byType(AppFormLabel));
      final box = tester.getRect(find.byKey(input));
      expect(label.height, about(20));
      expect(box.top - label.bottom, about(8));
      expect(box.height, about(44));
      expect(find.text('*'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).style.fontSize,
        12,
      );
    },
  );

  testWidgets('AppSelectField: a 40 box that is one button with its label', (
    tester,
  ) async {
    var taps = 0;
    const box = ValueKey('box');
    await pumpInApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: AppSelectField(
          label: 'Icon',
          placeholder: 'Choose an icon',
          boxKey: box,
          onTap: () => taps++,
        ),
      ),
    );
    expect(tester.getRect(find.byKey(box)).height, about(40));
    await tester.tap(find.text('Icon'));
    await tester.tap(find.text('Choose an icon'));
    expect(taps, 2);
  });

  testWidgets('AppDashedBox insets its content 8 by 4', (tester) async {
    const child = ValueKey('child');
    await pumpInApp(
      tester,
      const AppDashedBox(child: SizedBox(key: child, width: 100, height: 50)),
    );
    final outer = tester.getRect(find.byType(AppDashedBox));
    final inner = tester.getRect(find.byKey(child));
    expect(inner.left - outer.left, 8);
    expect(inner.top - outer.top, 4);
  });

  testWidgets('AppMapPreview: a 40 full-screen button 12 down, 7 in from '
      'the end; the pin only when asked', (tester) async {
    var opened = 0;
    Future<void> pump({required bool pin}) => pumpInApp(
      tester,
      SizedBox(
        width: 322,
        child: AppMapPreview(
          height: 171,
          showPin: pin,
          map: const ColoredBox(color: Colors.grey),
          fullscreenTooltip: 'Full screen',
          onFullscreen: () => opened++,
        ),
      ),
      locale: const Locale('ar'),
    );
    await pump(pin: true);
    final map = tester.getRect(find.byType(AppMapPreview));
    final button = tester.getRect(find.byKey(AppMapPreview.fullscreenKey));
    expect(map.height, 171);
    expect(button.size, const Size(40, 40));
    expect(button.top - map.top, 12);
    expect(button.left - map.left, 7, reason: 'the end is the left in RTL');
    expect(find.byType(AppMapPin), findsOneWidget);
    await tester.tapAt(button.center.translate(0, 22));
    expect(opened, 1, reason: 'the 40 button answers across 48');

    await pump(pin: false);
    expect(find.byType(AppMapPin), findsNothing);
  });

  testWidgets('AppFormBottomBar: 60 tall, cancel 99×44, primary fills', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: AppFormBottomBar(
          primaryLabel: 'Save changes',
          onPrimary: null,
          cancelLabel: 'Cancel',
          onCancel: () {},
        ),
      ),
      locale: const Locale('ar'),
    );
    final bar = tester.getRect(find.byType(AppFormBottomBar));
    final primary = tester.getRect(find.byKey(AppFormBottomBar.primaryKey));
    final cancel = tester.getRect(find.byKey(AppFormBottomBar.cancelKey));
    expect(bar.height, 60);
    expect(cancel.size, const Size(99, 44));
    expect(primary.height, 44);
    expect(primary.width, about(402 - 32 - 8 - 99));
    expect(primary.right, about(bar.right - 16), reason: 'start in RTL');
    final button = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(AppFormBottomBar.primaryKey),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.disabled}),
      AppColors.transparentBluePurple30,
    );
    expect(
      tester
          .widget<AppButton>(find.byKey(AppFormBottomBar.primaryKey))
          .onPressed,
      isNull,
    );
  });

  testWidgets('AppInfoSection: 12 title row, 10, a value box of at least 60', (
    tester,
  ) async {
    const value = ValueKey('value');
    await pumpInApp(
      tester,
      const Padding(
        padding: EdgeInsets.all(16),
        child: AppInfoSection(
          title: 'المعلومات الاساسيه',
          child: AppInfoValue(
            key: value,
            label: 'اسم نقطة الاهتمام',
            value: 'المستودع الرئيسي',
          ),
        ),
      ),
      locale: const Locale('ar'),
    );
    final section = tester.getRect(find.byType(AppInfoSection));
    final title = tester.getRect(find.text('المعلومات الاساسيه'));
    final box = tester.getRect(find.byKey(value));
    expect(title.top - section.top, 16);
    expect(title.height, about(12));
    expect(box.top - title.bottom, about(10));
    expect(box.height, about(60));
    expect(box.width, section.width - 16);
    final valueText = tester.widget<Text>(find.text('المستودع الرئيسي'));
    expect(valueText.style?.fontWeight, FontWeight.w700);
    expect(valueText.style?.fontSize, 14);
    final label = tester.widget<Text>(find.text('اسم نقطة الاهتمام'));
    expect(label.style?.fontSize, 10);
    expect(label.style?.color, AppColors.neutral600);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .ancestor(
                        of: find.text('المستودع الرئيسي'),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, AppColors.gray25);
  });

  testWidgets('the components meet the tap-target guidelines together', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpInApp(
      tester,
      Column(
        children: [
          AppPageHeader(
            title: 'Title',
            subtitle: 'Subtitle',
            onBack: () {},
            trailing: HitTargetExtender(
              child: AppOutlineIconButton(
                tooltip: 'Edit',
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppFormCard(
              title: 'Card',
              subtitle: 'Subtitle',
              children: [
                AppFormField(label: 'Name', controller: controller),
                AppSelectField(
                  label: 'Icon',
                  placeholder: 'Choose',
                  onTap: () {},
                ),
                AppMapPreview(
                  height: 112,
                  map: const ColoredBox(color: Colors.grey),
                  fullscreenTooltip: 'Full screen',
                  onFullscreen: () {},
                ),
              ],
            ),
          ),
          const Spacer(),
          AppFormBottomBar(
            primaryLabel: 'Save',
            onPrimary: () {},
            cancelLabel: 'Cancel',
            onCancel: () {},
          ),
        ],
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    // Not text contrast: the design's secondary grey (#818181) is 3.9:1 on
    // white. Logged in docs/backlog.md ("Secondary grey text under AA").
    semantics.dispose();
  });
}
