import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/new_password_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_rule_checklist.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, required this.resetToken, this.cubit});

  /// Proof that the one-time code was accepted. Without it there is nothing to
  /// authorise the change, so the screen cannot be reached on its own.
  final String resetToken;

  final NewPasswordCubit? cubit;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider<NewPasswordCubit>(
      create: (_) => widget.cubit ?? getIt<NewPasswordCubit>(),
      child: BlocConsumer<NewPasswordCubit, NewPasswordState>(
        listener: (context, state) {
          switch (state.status) {
            case AuthFormSucceeded():
              FocusManager.instance.primaryFocus?.unfocus();
              // Replace the flow: the code and reset token are spent.
              context.go(AppRoutes.passwordResetSuccess);
            case AuthFormFailed(:final failure):
              AppSnackBar.showError(context, failure.message);
            case AuthFormIdle() || AuthFormSubmitting():
              break;
          }
        },
        builder: (context, state) {
          final busy = state.status is AuthFormSubmitting;
          final cubit = context.read<NewPasswordCubit>();

          return AuthScaffold(
            title: l10n.newPasswordTitle,
            subtitle: l10n.newPasswordSubtitle,
            card: [
              AppTextField(
                label: l10n.newPasswordLabel,
                isRequired: true,
                obscureText: true,
                enabled: !busy,
                forceLtr: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: cubit.onPasswordChanged,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: l10n.newPasswordConfirmLabel,
                isRequired: true,
                obscureText: true,
                enabled: !busy,
                forceLtr: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: cubit.onConfirmationChanged,
              ),
              const SizedBox(height: AppSizes.p16),
              AppButton(
                onPressed: state.canSubmit
                    ? () => cubit.submit(widget.resetToken)
                    : null,
                label: l10n.newPasswordSubmit,
                isLoading: busy,
              ),
            ],
            // The design puts the checklist on the backdrop under the card,
            // not inside it, so the card stays the height of the form.
            below: [
              PasswordRuleChecklist(rules: state.rules, matches: state.matches),
            ],
          );
        },
      ),
    );
  }
}
