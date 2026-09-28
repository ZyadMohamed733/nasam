import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/extensions/context_extensions.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/new_password_cubit.dart';
import 'package:nasam/features/auth/presentation/pages/new_password_page.dart';
import 'package:nasam/features/auth/presentation/widgets/password_rule_checklist.dart';
import 'package:nasam/shared/widgets/app_button.dart';
import 'package:nasam/shared/widgets/app_text_field.dart';

import '../../helpers/recovery.dart';
import '../../helpers/widget_harness.dart';

class _Repository extends Mock implements AuthRepository {}

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets('match checklist and Save stay in sync ($language)', (
      tester,
    ) async {
      final repository = _Repository();
      final cubit = NewPasswordCubit(ResetPasswordUseCase(repository));
      await pumpInApp(
        tester,
        withRecovery(NewPasswordPage(cubit: cubit)),
        locale: Locale(language),
      );
      final context = tester.element(find.byType(NewPasswordPage));
      final matchLabel = context.l10n.passwordRuleMatches;
      final mismatchLabel = context.l10n.validationPasswordsDoNotMatch;

      void expectMatch({required bool matches, required bool canSave}) {
        expect(find.text(matchLabel), findsOneWidget);
        expect(find.text(mismatchLabel), findsNothing);
        final row = find
            .ancestor(of: find.text(matchLabel), matching: find.byType(Row))
            .first;
        final icon = tester.widget<Icon>(
          find.descendant(of: row, matching: find.byType(Icon)),
        );
        expect(
          icon.icon,
          matches ? Icons.check_circle_rounded : Icons.circle_outlined,
        );
        expect(
          icon.color,
          matches
              ? context.semanticColors.successText
              : context.semanticColors.failText,
        );
        expect(
          tester.widget<AppButton>(find.byType(AppButton)).onPressed != null,
          canSave,
        );
        expect(
          tester.widget<AppTextField>(find.byType(AppTextField).last).errorText,
          isNull,
        );
        expect(
          tester
              .widget<PasswordRuleChecklist>(find.byType(PasswordRuleChecklist))
              .matches,
          matches,
        );
      }

      Future<void> enter(int field, String value) async {
        await tester.enterText(find.byType(TextField).at(field), value);
        await tester.pump();
      }

      expectMatch(matches: false, canSave: false);
      await enter(0, 'StrongPass1!');
      expectMatch(matches: false, canSave: false);
      await enter(1, 'Strong');
      expectMatch(matches: false, canSave: false);
      await cubit.submit('token');
      verifyNever(
        () => repository.resetPassword(
          resetToken: any(named: 'resetToken'),
          newPassword: any(named: 'newPassword'),
        ),
      );
      await enter(1, 'StrongPass1!');
      expectMatch(matches: true, canSave: true);
      await enter(0, 'DifferentPass2!');
      expectMatch(matches: false, canSave: false);
      await enter(1, '');
      expectMatch(matches: false, canSave: false);
      await enter(0, 'weak');
      await enter(1, 'weak');
      expectMatch(matches: true, canSave: false);
      await enter(0, '');
      await enter(1, '');
      expectMatch(matches: false, canSave: false);
      expect(tester.takeException(), isNull);
    });
  }
}
