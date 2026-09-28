import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/failure_l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_otp_input.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/password_recovery_cubit.dart';
import '../widgets/auth_scaffold.dart';

/// Password recovery, step two: the six-digit code emailed in step one.
///
/// The same screen design as login's second factor, but its own page and
/// state: this code earns a reset token, not a session. Expects the flow's
/// [PasswordRecoveryCubit] above it.
class ResetCodePage extends StatefulWidget {
  const ResetCodePage({super.key});

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  /// The API's code is six digits, handled as a string throughout.
  static const int _codeLength = 6;

  String _code = '';

  @override
  void initState() {
    super.initState();
    // Reached without a code having been sent — a cold start or a restored
    // route into the middle of the flow: start it properly.
    if (context.read<PasswordRecoveryCubit>().state.email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.forgotPassword);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PasswordRecoveryCubit>();

    return BlocListener<PasswordRecoveryCubit, PasswordRecoveryState>(
      listenWhen: (previous, current) => previous.resend != current.resend,
      listener: (context, state) {
        switch (state.resend) {
          case AuthFormSucceeded():
            AppSnackBar.showSuccess(context, l10n.resetCodeResent);
          case AuthFormFailed(:final failure):
            AppSnackBar.showError(context, failure.resolve(context));
          case AuthFormIdle() || AuthFormSubmitting() || LoginNeedsOtp():
            break;
        }
      },
      child: BlocConsumer<PasswordRecoveryCubit, PasswordRecoveryState>(
        listenWhen: (previous, current) => previous.verify != current.verify,
        listener: (context, state) {
          // Only a token opens the next step; the repository has already
          // turned a response without one into a failure.
          if (state.verify is AuthFormSucceeded && state.hasResetToken) {
            context.push(AppRoutes.newPassword);
          }
        },
        builder: (context, state) {
          final busy = state.verify is AuthFormSubmitting;
          final failure = switch (state.verify) {
            AuthFormFailed(:final failure) => failure,
            _ => null,
          };

          return AuthScaffold(
            title: l10n.otpTitle,
            subtitle: l10n.otpSubtitle,
            card: [
              AppOtpInput(
                length: _codeLength,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: (value) {
                  _code = value;
                  cubit.verifyCode(value);
                },
                // Same endpoint as the first send; the countdown restarts
                // in the widget, with no expiry invented here.
                onResend: state.resend is AuthFormSubmitting
                    ? null
                    : cubit.resendCode,
                errorText: failure?.resolve(context),
                action: AppButton(
                  onPressed: busy || _code.length < _codeLength
                      ? null
                      : () => cubit.verifyCode(_code),
                  label: l10n.otpSubmit,
                  isLoading: busy,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
