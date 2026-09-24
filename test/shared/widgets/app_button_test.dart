import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_colors.dart';
import 'package:nasam/core/constants/app_icons.dart';
import 'package:nasam/core/constants/app_sizes.dart';
import 'package:nasam/shared/widgets/app_button.dart';

import '../../helpers/widget_harness.dart';

void main() {
  group('AppButton', () {
    testWidgets('is the design height and full width by default', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const AppButton(onPressed: _noop, label: 'Continue'),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, AppSizes.buttonHeight);
      // Center gives it the full width of the surface.
      expect(
        size.width,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
    });

    testWidgets('honours an explicit width', (tester) async {
      await pumpInApp(
        tester,
        const AppButton(
          onPressed: _noop,
          label: 'Continue',
          width: AppSizes.formContentWidth,
        ),
      );

      expect(
        tester.getSize(find.byType(AppButton)).width,
        AppSizes.formContentWidth,
      );
    });

    testWidgets('draws its icon at the design inline size', (tester) async {
      await pumpInApp(
        tester,
        const AppButton(
          onPressed: _noop,
          label: 'Continue',
          icon: AppIcons.user,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(AppIcons.user));
      expect(icon.size, AppIconSize.small.value);
    });

    // The design names a disabled colour, so the button must not fake one with
    // opacity — an Opacity wrapper also forces a saveLayer on every button.
    testWidgets('disabled uses the design token, not an opacity layer', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        const AppButton(onPressed: null, label: 'Continue'),
      );

      expect(find.byType(Opacity), findsNothing);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
        button.style?.backgroundColor?.resolve({WidgetState.disabled}),
        AppSemanticColors.light.primaryButtonDisabled,
      );
    });

    testWidgets('a loading button cannot be pressed', (tester) async {
      var pressed = 0;
      await pumpInApp(
        tester,
        AppButton(
          onPressed: () => pressed++,
          label: 'Continue',
          isLoading: true,
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(pressed, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('each variant renders its own button type', (tester) async {
      for (final (variant, matcher) in [
        (AppButtonVariant.primary, find.byType(ElevatedButton)),
        (AppButtonVariant.secondary, find.byType(OutlinedButton)),
        (AppButtonVariant.tertiary, find.byType(TextButton)),
      ]) {
        await pumpInApp(
          tester,
          AppButton(onPressed: _noop, label: 'Continue', variant: variant),
        );
        expect(matcher, findsOneWidget, reason: '$variant');
      }
    });

    testWidgets('resolves colours from the dark theme too', (tester) async {
      await pumpInApp(
        tester,
        const AppButton(onPressed: _noop, label: 'Continue'),
        dark: true,
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(
        button.style?.backgroundColor?.resolve(<WidgetState>{}),
        AppSemanticColors.dark.primaryButtonBackground,
      );
    });
  });
}

void _noop() {}
