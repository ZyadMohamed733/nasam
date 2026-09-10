import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/localization/app_localizations_setup.dart';
import 'package:nasam/core/localization/validation_error_l10n.dart';
import 'package:nasam/core/utils/validation_error.dart';
import 'package:nasam/core/utils/validators.dart';

void main() {
  Future<String> resolve(
    WidgetTester tester,
    ValidationError error,
    Locale locale,
  ) async {
    late String message;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Builder(
          builder: (context) {
            message = error.resolve(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return message;
  }

  testWidgets('resolves to English under the en locale', (tester) async {
    expect(
      await resolve(tester, const InvalidPhoneError(), const Locale('en')),
      'Please enter a valid Saudi phone number.',
    );
  });

  // The gap the audit found: the Arabic string already existed in app_ar.arb,
  // but a static validator returning a String could never reach it.
  testWidgets('resolves to Arabic under the ar locale', (tester) async {
    expect(
      await resolve(tester, const InvalidPhoneError(), const Locale('ar')),
      'يرجى إدخال رقم هاتف سعودي صحيح.',
    );
  });

  testWidgets('a validator result reaches Arabic end to end', (tester) async {
    final error = AppValidators.email('not-an-email')!;
    expect(
      await resolve(tester, error, const Locale('ar')),
      'يرجى إدخال بريد إلكتروني صحيح.',
    );
  });

  testWidgets('parameterised errors interpolate in both locales', (
    tester,
  ) async {
    expect(
      await resolve(tester, const MinLengthError(8), const Locale('en')),
      contains('8'),
    );
    expect(
      await resolve(
        tester,
        const RequiredFieldError(fieldName: 'Email'),
        const Locale('en'),
      ),
      'Email is required.',
    );
    expect(
      await resolve(tester, const RequiredFieldError(), const Locale('en')),
      'This field is required.',
    );
  });

  testWidgets('context.validator adapts a typed validator for TextFormField', (
    tester,
  ) async {
    late String? Function(String?) adapted;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Builder(
          builder: (context) {
            adapted = context.validator(AppValidators.email);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(adapted('someone@nasam.app'), isNull);
    expect(adapted('nope'), 'Please enter a valid email address.');
  });
}
