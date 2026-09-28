import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/failure_l10n.dart';
import '../../../../core/localization/validation_error_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/password_recovery_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';

/// Password recovery, step one: the email the code goes to.
///
/// Expects the flow's [PasswordRecoveryCubit] above it (the router's
/// recovery shell provides it).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    // Starting over keeps the address already entered.
    _email = TextEditingController(
      text: context.read<PasswordRecoveryCubit>().state.email,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordRecoveryCubit>().requestCode(_email.text);
  }

  /// Back to sign in: a pop when login is underneath, as it is when the
  /// user came from there; otherwise (after starting over) a fresh login.
  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<PasswordRecoveryCubit, PasswordRecoveryState>(
      listenWhen: (previous, current) => previous.request != current.request,
      listener: (context, state) {
        switch (state.request) {
          case AuthFormSucceeded():
            context.push(AppRoutes.resetCode);
          case AuthFormFailed(:final failure):
            AppSnackBar.showError(context, failure.resolve(context));
          case AuthFormIdle() || AuthFormSubmitting() || LoginNeedsOtp():
            break;
        }
      },
      buildWhen: (previous, current) => previous.request != current.request,
      builder: (context, state) {
        final busy = state.request is AuthFormSubmitting;

        return AuthScaffold(
          title: l10n.forgotPasswordTitle,
          subtitle: l10n.forgotPasswordSubtitle,
          card: [
            Form(
              key: _formKey,
              child: AppTextField(
                controller: _email,
                label: l10n.loginEmailLabel,
                isRequired: true,
                hint: l10n.loginEmailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enabled: !busy,
                forceLtr: true,
                validator: context.validator(AppValidators.email),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            AppButton(
              onPressed: busy ? null : () => _submit(context),
              label: l10n.forgotPasswordSubmit,
              isLoading: busy,
            ),
            const SizedBox(height: AppSizes.p8),
            Align(
              child: AuthLink(
                onPressed: busy ? null : () => _backToLogin(context),
                label: l10n.authBackToLogin,
                trailingIcon: AppIcons.forward,
              ),
            ),
          ],
        );
      },
    );
  }
}
