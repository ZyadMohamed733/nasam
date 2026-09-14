import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/validation_error_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/forgot_password_cubit.dart';
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
          switch (state) {
            case AuthFormSucceeded():
              // The address travels with the route: the verify step has to
              // quote it back to the user and send it with the code.
              context.push(
                AppRoutes.otpVerification,
                extra: _email.text.trim(),
              );
            case AuthFormFailed(:final failure):
              AppSnackBar.showError(context, failure.message);
            case AuthFormIdle() || AuthFormSubmitting():
              break;
          }
        },
        builder: (context, state) {
          final busy = state is AuthFormSubmitting;

          return AuthScaffold(
            title: l10n.forgotPasswordTitle,
            subtitle: l10n.forgotPasswordSubtitle,
            children: [
              Form(
                key: _formKey,
                child: AppTextField(
                  controller: _email,
                  label: l10n.loginEmailLabel,
                  hint: l10n.loginEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.username],
                  enabled: !busy,
                  forceLtr: true,
                  validator: context.validator(AppValidators.email),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  context.read<ForgotPasswordCubit>().submit(_email.text);
                },
                label: l10n.forgotPasswordSubmit,
                isLoading: busy,
              ),
            ],
          );
        },
      ),
    );
  }
}
