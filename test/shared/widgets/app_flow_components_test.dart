import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/theme/app_component_colors.dart';
import 'package:nasam/core/theme/app_status_tones.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_data_table.dart';
import 'package:nasam/shared/widgets/app_file_drop_zone.dart';
import 'package:nasam/shared/widgets/app_form_bottom_bar.dart';
import 'package:nasam/shared/widgets/app_page_header.dart';
import 'package:nasam/shared/widgets/app_pagination.dart';
import 'package:nasam/shared/widgets/app_status_chip.dart';
import 'package:nasam/shared/widgets/app_stepper.dart';
import 'package:nasam/shared/widgets/app_summary_tile.dart';
import 'package:nasam/shared/widgets/hit_target.dart';

import '../../helpers/widget_harness.dart';

const _ar = Locale('ar');
const _steps = ['رفع الملف', 'التحقق', 'المعاينة', 'تأكيد'];

Future<void> _tapTargets(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  group('AppStepper', () {
    for (final (locale, rtl) in [(_ar, true), (const Locale('en'), false)]) {
      testWidgets('${locale.languageCode}: 36 tall, step 1 at the start', (
        tester,
      ) async {
        await pumpInApp(
          tester,
          const SizedBox(
            width: 370,
            child: AppStepper(steps: _steps, current: 1),
          ),
          locale: locale,
        );
        final stepper = tester.getRect(find.byType(AppStepper));
        expect(stepper.height, 36);
        final first = tester.getCenter(find.text(_steps.first));
        final second = tester.getCenter(find.text(_steps[1]));
        expect(rtl ? first.dx > second.dx : first.dx < second.dx, isTrue);
      });
    }

    testWidgets('done, current and still-to-come steps', (tester) async {
      await pumpInApp(
        tester,
        const SizedBox(
          width: 370,
          child: AppStepper(steps: _steps, current: 1),
        ),
        locale: _ar,
      );
      expect(find.byIcon(Icons.check), findsOneWidget, reason: 'step 1 done');
      final colors = AppComponentColors.light;
      Text label(String s) => tester.widget<Text>(find.text(s));
      expect(label(_steps[0]).style?.fontWeight, FontWeight.w700);
      expect(label(_steps[1]).style?.fontWeight, FontWeight.w700);
      expect(label(_steps[1]).style?.fontSize, 14);
      expect(label(_steps[2]).style?.fontSize, 12);
      expect(label(_steps[2]).style?.color, colors.stepperInactiveLabel);
      expect(label(_steps[0]).style?.color, colors.stepperDoneLabel);
    });

    testWidgets('a current past the end marks every step done', (tester) async {
      await pumpInApp(
        tester,
        const SizedBox(
          width: 370,
          child: AppStepper(steps: _steps, current: 4),
        ),
      );
      expect(find.byIcon(Icons.check), findsNWidgets(4));
    });
  });

  group('AppStatusChip', () {
    testWidgets('a 32-tall filter chip: label then count badge, tone colours, '
        'border when selected, 48 target', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpInApp(
        tester,
        HitTargetScope(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppStatusChip(
              tone: AppTone.info,
              label: 'الكل',
              count: 9,
              selected: true,
              onTap: () => taps++,
            ),
          ),
        ),
        locale: _ar,
      );
      final chip = tester.getRect(find.byType(Material).last);
      expect(chip.height, 32);
      expect(chip.width, greaterThanOrEqualTo(102));
      final label = tester.getCenter(find.text('الكل'));
      final count = tester.getCenter(find.text('9'));
      expect(label.dx, greaterThan(count.dx), reason: 'badge after, in RTL');
      final material = tester.widget<Material>(find.byType(Material).last);
      final tone = AppStatusTones.light.info;
      expect(material.color, tone.background);
      expect(
        (material.shape! as RoundedRectangleBorder).side.color,
        tone.border,
      );
      await tester.tapAt(chip.topCenter.translate(0, -7));
      expect(taps, 1, reason: '7 above the 32 chip is inside the 48');
      await _tapTargets(tester);
      semantics.dispose();
    });

    testWidgets('without onTap it is a plain label: no border, no badge', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const AppStatusChip(tone: AppTone.success, label: 'صحيح'),
        locale: _ar,
      );
      final material = tester.widget<Material>(find.byType(Material).last);
      expect((material.shape! as RoundedRectangleBorder).side, BorderSide.none);
      expect(find.byType(HitTargetExtender), findsNothing);
    });
  });

  group('AppDataTable', () {
    const columns = [
      AppDataColumn(label: 'الاسم', width: 131),
      AppDataColumn(label: 'خط العرض', width: 74),
      AppDataColumn(label: 'الحالة', width: 97, sortable: true),
    ];
    AppDataRow row(bool flagged) => AppDataRow(
      flagged: flagged,
      cells: const [Text('a'), Text('24.7'), Text('ok')],
    );

    testWidgets('36 header, 48 rows, design widths stretched to fill; the '
        'first column at the start', (tester) async {
      await pumpInApp(
        tester,
        SizedBox(
          width: 370,
          child: AppDataTable(columns: columns, rows: [row(false), row(true)]),
        ),
        locale: _ar,
      );
      final header = tester.getRect(find.text('الاسم'));
      final table = tester.getRect(find.byType(AppDataTable));
      expect(table.width, 370);
      expect(header.center.dx, greaterThan(table.center.dx), reason: 'RTL');
      final cells = find.ancestor(
        of: find.text('24.7'),
        matching: find.byType(Container),
      );
      expect(tester.getRect(cells.first).height, 48);
      expect(tester.getRect(cells.first).width, closeTo(74 * 370 / 302, .5));
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    });

    testWidgets('scrolls sideways when the columns are wider than the space', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        SizedBox(
          width: 200,
          child: AppDataTable(columns: columns, rows: [row(false)]),
        ),
        locale: _ar,
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppPagination', () {
    testWidgets('40 tall, 32 buttons with the current page filled, total at '
        'the end, 48 targets', (tester) async {
      final semantics = tester.ensureSemantics();
      final pages = <int>[];
      await pumpInApp(
        tester,
        HitTargetScope(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 370,
              child: AppPagination(
                page: 0,
                pageCount: 3,
                totalLabel: 'إجمالي 24 poi',
                onPage: pages.add,
              ),
            ),
          ),
        ),
        locale: _ar,
      );
      expect(tester.getRect(find.byType(AppPagination)).height, 40);
      final one = tester.getRect(find.byKey(AppPagination.pageKey(0)));
      final two = tester.getRect(find.byKey(AppPagination.pageKey(1)));
      expect(one.size, const Size(32, 32));
      expect(one.left, greaterThan(two.left), reason: 'page 1 first, in RTL');
      expect(
        tester.getCenter(find.text('إجمالي 24 poi')).dx,
        lessThan(two.left),
      );
      await tester.tapAt(two.center.translate(0, -20));
      expect(pages, [1]);
      await _tapTargets(tester);
      semantics.dispose();
    });

    testWidgets('a window of 3 pages around the current one', (tester) async {
      await pumpInApp(
        tester,
        HitTargetScope(
          child: AppPagination(
            page: 5,
            pageCount: 20,
            totalLabel: 'Total 200',
            onPage: (_) {},
          ),
        ),
      );
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });
  });

  testWidgets('AppFileDropZone: the whole zone browses; hint and title', (
    tester,
  ) async {
    var browses = 0;
    await pumpInApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: AppFileDropZone(
          title: 'اسحب الملفات هنا أو انقر للاستعراض',
          hint: '.xlsx بحد أقصى 20MB',
          browseLabel: 'استعراض الملفات',
          onBrowse: () => browses++,
        ),
      ),
      locale: _ar,
    );
    await tester.tap(find.text('اسحب الملفات هنا أو انقر للاستعراض'));
    await tester.tap(find.text('استعراض الملفات'));
    expect(browses, 2);
    final button = tester.getRect(
      find
          .ancestor(
            of: find.text('استعراض الملفات'),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(button.size, const Size(132, 40));
  });

  testWidgets('AppSummaryTile: value over label, tone fill, 82 tall', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      const SizedBox(
        width: 78.5,
        child: AppSummaryTile(
          tone: AppTone.success,
          value: 4,
          label: 'تم تنزيل بنجاح',
        ),
      ),
      locale: _ar,
    );
    expect(tester.getRect(find.byType(AppSummaryTile)).height, 82);
    final value = tester.widget<Text>(find.text('4'));
    expect(value.style?.color, AppStatusTones.light.success.foreground);
    expect(value.style?.fontWeight, FontWeight.w700);
    expect(
      tester.getCenter(find.text('4')).dy,
      lessThan(tester.getCenter(find.text('تم تنزيل بنجاح')).dy),
    );
  });

  testWidgets('AppPageHeader draws its divider only when asked', (
    tester,
  ) async {
    Future<int> borders({required bool divider}) async {
      await pumpInApp(
        tester,
        AppPageHeader(title: 'رفع', subtitle: 'قم', showDivider: divider),
        locale: _ar,
      );
      return find
          .descendant(
            of: find.byType(AppPageHeader),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).border?.bottom.color ==
                      AppComponentColors.light.headerDivider,
            ),
          )
          .evaluate()
          .length;
    }

    expect(await borders(divider: true), 1);
    expect(await borders(divider: false), 0);
    expect(tester.getRect(find.byType(AppPageHeader)).height, 71);
  });

  testWidgets('AppFormBottomBar can end with a text button', (tester) async {
    await pumpInApp(
      tester,
      AppFormBottomBar(
        primaryLabel: 'المعاينة',
        onPrimary: () {},
        cancelLabel: 'السابق',
        onCancel: () {},
        cancelVariant: AppButtonVariant.tertiary,
      ),
      locale: _ar,
    );
    expect(
      find.descendant(
        of: find.byKey(AppFormBottomBar.cancelKey),
        matching: find.byType(TextButton),
      ),
      findsOneWidget,
    );
  });
}
