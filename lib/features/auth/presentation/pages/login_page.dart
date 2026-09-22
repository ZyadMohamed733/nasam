import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/validation_error_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/login_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.cubit});

  /// Injected in tests; resolved from the container otherwise.
  final LoginCubit? cubit;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().submit(
      username: _username.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider<LoginCubit>(
      create: (_) => widget.cubit ?? getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, AuthFormStatus>(
        listener: (context, state) {
          switch (state) {
            case AuthFormSucceeded():
              // The repository has already stored the session, so RouteGuard
              // will let this through.
              context.go(AppRoutes.home);
            case LoginNeedsOtp(:final username):
              context.push(AppRoutes.otpVerification, extra: username);
            case AuthFormFailed(:final failure):
              AppSnackBar.showError(context, failure.message);
            case AuthFormIdle() || AuthFormSubmitting():
              break;
          }
        },
        builder: (context, state) {
          final busy = state is AuthFormSubmitting;

          return AuthScaffold(
            title: l10n.loginTitle,
            subtitle: l10n.loginSubtitle,
            card: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _username,
                      label: l10n.loginUsernameLabel,
                      isRequired: true,
                      hint: l10n.loginUsernameHint,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      enabled: !busy,
                      validator: context.validator(
                        (v) => AppValidators.required(v),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppTextField(
                      controller: _password,
                      label: l10n.loginPasswordLabel,
                      isRequired: true,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !busy,
                      forceLtr: true,
                      // Only that something was entered. Applying the strength
                      // rules here would tell an attacker which of the stored
                      // passwords could not exist, and would lock out any user
                      // whose password predates the current policy.
                      validator: context.validator(
                        (v) => AppValidators.required(v),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AuthLink(
                  onPressed: busy
                      ? null
                      : () => context.push(AppRoutes.forgotPassword),
                  label: l10n.loginForgotPassword,
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              AppButton(
                onPressed: () => _submit(context),
                label: l10n.loginSubmit,
                isLoading: busy,
              ),
            ],
            below: [
              if (kDebugMode && !getIt<AppConfig>().isProd)
                _FlavorDebugBanner(config: getIt<AppConfig>()),
            ],
          );
        },
      ),
    );
  }
}

/// Never in a release build, and never in production: this prints the API and
/// socket hosts to anyone who reaches the login screen.
class _FlavorDebugBanner extends StatelessWidget {
  const _FlavorDebugBanner({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final color = switch (config.flavor) {
      Flavor.dev => Colors.green,
      Flavor.staging => Colors.orange,
      Flavor.prod => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.flavor.name.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p4),
          Text('App name: ${config.appName}'),
          Text('Base URL: ${config.baseUrl}'),
          Text('WS URL: ${config.wsUrl}'),
        ],
      ),
    );
  }
}
