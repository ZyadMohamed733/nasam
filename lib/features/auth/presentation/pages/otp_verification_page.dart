import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_otp_input.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../cubit/auth_form_status.dart';
import '../cubit/otp_cubit.dart';
import '../widgets/auth_scaffold.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.username,
    this.cubit,
    this.returnTo,
  });

  /// The account this login's second factor belongs to. Threaded from
  /// `LoginPage` via the route `extra`, not re-derived: the screen cannot be
  /// reached without it.
  final String username;

  /// Where to go once verified — the target a deep link carried to login.
  final String? returnTo;

  final OtpCubit? cubit;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  /// The API's code is six digits.
  static const int _codeLength = 6;

  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider<OtpCubit>(
      create: (_) => widget.cubit ?? getIt<OtpCubit>(),
      child: BlocConsumer<OtpCubit, AuthFormStatus>(
        listener: (context, state) {
          switch (state) {
            case AuthFormSucceeded():
              // The repository has already stored the session, so RouteGuard
              // will let this through.
              context.go(widget.returnTo ?? AppRoutes.home);
            case AuthFormFailed(:final failure):
              AppSnackBar.showError(context, failure.message);
            case AuthFormIdle() || AuthFormSubmitting() || LoginNeedsOtp():
              break;
          }
        },
        builder: (context, state) {
          final busy = state is AuthFormSubmitting;
          final cubit = context.read<OtpCubit>();

          return AuthScaffold(
            title: l10n.otpTitle,
            subtitle: l10n.otpSubtitle,
            card: [
              AppOtpInput(
                length: _codeLength,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: (value) {
                  _code = value;
                  cubit.submit(username: widget.username, code: value);
                },
                onResend: () => cubit.resend(widget.username),
                errorText: state is AuthFormFailed
                    ? state.failure.message
                    : null,
                action: AppButton(
                  // Completing the last box submits on its own; this is the
                  // explicit path for anyone who pastes or edits a digit.
                  onPressed: _code.length < _codeLength
                      ? null
                      : () => cubit.submit(
                          username: widget.username,
                          code: _code,
                        ),
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
