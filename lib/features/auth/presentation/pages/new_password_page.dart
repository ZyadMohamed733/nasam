import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/failure_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/new_password_cubit.dart';
import '../cubit/password_recovery_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_rule_checklist.dart';

/// Password recovery, step three: the new password.
///
/// The reset token comes from the flow's [PasswordRecoveryCubit], never from
/// the route. Leaving this screen — back, or on to success — drops it.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, this.cubit});

  /// Injected in tests; resolved from the container otherwise.
  final NewPasswordCubit? cubit;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  @override
  void initState() {
    super.initState();
    // No token: reached without a verified code (a cold start, a restored
    // route). There is nothing this screen can submit, so start over.
    if (!context.read<PasswordRecoveryCubit>().state.hasResetToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.forgotPassword);
      });
    }
  }

  /// Back to the email step with a clean slate: the token is dropped, and a
  /// new code is needed. Offered after a failure, because a rejected token
  /// (expired, already used) and a rejected password both arrive as a 400
  /// and only the message tells them apart.
  void _startOver(BuildContext context) {
    context.read<PasswordRecoveryCubit>().clearResetToken();
    context.go(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recovery = context.read<PasswordRecoveryCubit>();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) recovery.clearResetToken();
      },
      child: BlocProvider<NewPasswordCubit>(
        create: (_) => widget.cubit ?? getIt<NewPasswordCubit>(),
        child: BlocConsumer<NewPasswordCubit, NewPasswordState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            switch (state.status) {
              case AuthFormSucceeded():
                FocusManager.instance.primaryFocus?.unfocus();
                recovery.clearResetToken();
                // Replaces the whole flow: login comes after the success
                // screen, with no recovery screen left to go back to.
                context.go(AppRoutes.passwordResetSuccess);
              case AuthFormFailed(:final failure):
                AppSnackBar.showError(context, failure.resolve(context));
              case AuthFormIdle() || AuthFormSubmitting() || LoginNeedsOtp():
                break;
            }
          },
          builder: (context, state) {
            final busy = state.status is AuthFormSubmitting;
            final cubit = context.read<NewPasswordCubit>();
            final token = recovery.resetToken;

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
                  onPressed: state.canSubmit && !busy && token != null
                      ? () => cubit.submit(token)
                      : null,
                  label: l10n.newPasswordSubmit,
                  isLoading: busy,
                ),
                if (state.status is AuthFormFailed) ...[
                  const SizedBox(height: AppSizes.p8),
                  Align(
                    child: AuthLink(
                      onPressed: () => _startOver(context),
                      label: l10n.resetStartOver,
                      trailingIcon: AppIcons.forward,
                    ),
                  ),
                ],
              ],
              // The design puts the checklist on the backdrop under the card,
              // not inside it, so the card stays the height of the form.
              below: [
                PasswordRuleChecklist(
                  rules: state.rules,
                  matches: state.matches,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
