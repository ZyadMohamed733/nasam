import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
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
  const OtpVerificationPage({super.key, required this.email, this.cubit});

  /// The address the code was sent to. Quoted back to the user and sent with
  /// the code, so the screen cannot be reached without it.
  final String email;

  final OtpCubit? cubit;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider<OtpCubit>(
      create: (_) => widget.cubit ?? getIt<OtpCubit>(),
      child: BlocConsumer<OtpCubit, AuthFormStatus>(
        listener: (context, state) {
          switch (state) {
            case OtpVerified(:final resetToken):
              // The reset token travels with the route rather than being
              // re-derived: the next screen must not have to hold the code.
              context.push(AppRoutes.newPassword, extra: resetToken);
            case AuthFormFailed(:final failure):
              AppSnackBar.showError(context, failure.message);
            case AuthFormIdle() ||
                AuthFormSubmitting() ||
                AuthFormSucceeded():
              break;
          }
        },
        builder: (context, state) {
          final busy = state is AuthFormSubmitting;
          final cubit = context.read<OtpCubit>();

          return AuthScaffold(
            title: l10n.otpTitle,
            subtitle: l10n.otpSubtitle(widget.email),
            children: [
              Align(
                child: AppOtpInput(
                  onChanged: (value) => setState(() => _code = value),
                  onCompleted: (value) {
                    _code = value;
                    cubit.submit(email: widget.email, code: value);
                  },
                  onResend: () => cubit.resend(widget.email),
                  errorText: state is AuthFormFailed
                      ? state.failure.message
                      : null,
                ),
              ),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                // Completing the last box submits on its own; this is the
                // explicit path for anyone who pastes or edits a digit.
                onPressed: _code.length < 6
                    ? null
                    : () => cubit.submit(email: widget.email, code: _code),
                label: l10n.otpSubmit,
                isLoading: busy,
              ),
            ],
          );
        },
      ),
    );
  }
}
