import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/password_recovery_cubit.dart';

class MockForgetPassword extends Mock implements ForgetPasswordUseCase {}

class MockVerifyResetOtp extends Mock implements VerifyResetOtpUseCase {}

/// A recovery flow already at [resetToken] (or earlier), for screens that
/// expect the router's recovery shell above them.
PasswordRecoveryCubit recoveryAt({
  String email = 'user@example.com',
  String? resetToken = 'verified-token',
  ForgetPasswordUseCase? forgetPassword,
  VerifyResetOtpUseCase? verifyResetOtp,
}) => PasswordRecoveryCubit(
  forgetPassword ?? MockForgetPassword(),
  verifyResetOtp ?? MockVerifyResetOtp(),
  initial: PasswordRecoveryState(email: email),
  resetToken: resetToken,
);

/// [child] under [recovery], as the recovery shell provides it.
Widget withRecovery(Widget child, {PasswordRecoveryCubit? recovery}) =>
    BlocProvider<PasswordRecoveryCubit>(
      create: (_) => recovery ?? recoveryAt(),
      child: child,
    );
