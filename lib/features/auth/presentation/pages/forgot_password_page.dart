import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/validation_error_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/success_screen.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/forgot_password_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.cubit});

  final ForgotPasswordCubit? cubit;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => widget.cubit ?? getIt<ForgotPasswordCubit>(),
      child: BlocConsumer<ForgotPasswordCubit, AuthFormStatus>(
        listener: (context, state) {
          // Success has no follow-up action to take -- see the builder
          // below, which swaps in the confirmation screen in place rather
          // than navigating. Password reset is web-only for now: the API
          // sends a link, not a code, so there is no next in-app step (see
          // docs/plans/AUTH_INTEGRATION_PLAN.md).
          if (state case AuthFormFailed(:final failure)) {
            AppSnackBar.showError(context, failure.message);
          }
        },
        builder: (context, state) {
          if (state is AuthFormSucceeded) {
            return SuccessScreen(
              title: l10n.forgotPasswordCheckEmailTitle,
              message: l10n.forgotPasswordCheckEmailSubtitle,
              actionLabel: l10n.authBackToLogin,
              onAction: () => context.go(AppRoutes.login),
            );
          }

          final busy = state is AuthFormSubmitting;

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
                  autofillHints: const [AutofillHints.username],
                  enabled: !busy,
                  forceLtr: true,
                  validator: context.validator(AppValidators.email),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              AppButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  context.read<ForgotPasswordCubit>().submit(_email.text);
                },
                label: l10n.forgotPasswordSubmit,
                isLoading: busy,
              ),
              const SizedBox(height: AppSizes.p8),
              Align(
                child: AuthLink(
                  onPressed: busy ? null : context.pop,
                  label: l10n.authBackToLogin,
                  trailingIcon: AppIcons.forward,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
