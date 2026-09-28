import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/presentation/cubit/auth_form_status.dart';
import 'package:nasam/features/auth/presentation/cubit/password_recovery_cubit.dart';

import '../../../../helpers/recovery.dart';

const _email = 'user@example.com';
const _sent = PasswordRecoveryState(
  email: _email,
  request: AuthFormSucceeded(),
);

void main() {
  late MockForgetPassword forget;
  late MockVerifyResetOtp verifyOtp;

  setUp(() {
    forget = MockForgetPassword();
    verifyOtp = MockVerifyResetOtp();
    when(() => forget(any())).thenAnswer((_) async => const Right(unit));
    when(
      () => verifyOtp(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => const Right('tok-1'));
  });

  PasswordRecoveryCubit build() => PasswordRecoveryCubit(forget, verifyOtp);

  group('requestCode', () {
    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'sends the trimmed email and remembers it',
      build: build,
      act: (c) => c.requestCode('  $_email '),
      expect: () => const [
        PasswordRecoveryState(request: AuthFormSubmitting()),
        _sent,
      ],
      verify: (_) => verify(() => forget(_email)).called(1),
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a double tap sends once',
      setUp: () {
        final gate = Completer<Either<Failure, Unit>>();
        when(() => forget(any())).thenAnswer((_) => gate.future);
        Future<void>.delayed(
          Duration.zero,
          () => gate.complete(const Right(unit)),
        );
      },
      build: build,
      act: (c) => Future.wait([c.requestCode(_email), c.requestCode(_email)]),
      verify: (_) => verify(() => forget(_email)).called(1),
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a failure is reported and remembers no email',
      setUp: () => when(() => forget(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'No account.', code: '404')),
      ),
      build: build,
      act: (c) => c.requestCode(_email),
      expect: () => const [
        PasswordRecoveryState(request: AuthFormSubmitting()),
        PasswordRecoveryState(
          request: AuthFormFailed(
            ServerFailure(message: 'No account.', code: '404'),
          ),
        ),
      ],
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'starting over drops a token from an earlier code',
      build: () =>
          recoveryAt(forgetPassword: forget, verifyResetOtp: verifyOtp),
      act: (c) => c.requestCode(_email),
      verify: (c) {
        expect(c.state.hasResetToken, isFalse);
        expect(c.resetToken, isNull);
      },
    );
  });

  group('resendCode', () {
    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'resends to the same email through the same endpoint',
      build: build,
      seed: () => _sent,
      act: (c) => c.resendCode(),
      expect: () => const [
        PasswordRecoveryState(
          email: _email,
          request: AuthFormSucceeded(),
          resend: AuthFormSubmitting(),
        ),
        PasswordRecoveryState(
          email: _email,
          request: AuthFormSucceeded(),
          resend: AuthFormSucceeded(),
        ),
      ],
      verify: (_) => verify(() => forget(_email)).called(1),
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a resend already out is not sent twice',
      setUp: () {
        final gate = Completer<Either<Failure, Unit>>();
        when(() => forget(any())).thenAnswer((_) => gate.future);
        Future<void>.delayed(
          Duration.zero,
          () => gate.complete(const Right(unit)),
        );
      },
      build: build,
      seed: () => _sent,
      act: (c) => Future.wait([c.resendCode(), c.resendCode()]),
      verify: (_) => verify(() => forget(_email)).called(1),
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a failed resend is reported, and can be tried again',
      setUp: () => when(() => forget(any())).thenAnswer(
        (_) async => const Left(RateLimitFailure(message: 'Slow down.')),
      ),
      build: build,
      seed: () => _sent,
      act: (c) async {
        await c.resendCode();
        await c.resendCode();
      },
      verify: (c) {
        verify(() => forget(_email)).called(2);
        expect(c.state.resend, isA<AuthFormFailed>());
      },
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'with no code sent yet there is nothing to resend',
      build: build,
      act: (c) => c.resendCode(),
      expect: () => const <PasswordRecoveryState>[],
    );
  });

  group('verifyCode', () {
    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'sends the code as typed, leading zero included, and keeps the token',
      build: build,
      seed: () => _sent,
      act: (c) => c.verifyCode('012345'),
      expect: () => const [
        PasswordRecoveryState(
          email: _email,
          request: AuthFormSucceeded(),
          verify: AuthFormSubmitting(),
        ),
        PasswordRecoveryState(
          email: _email,
          hasResetToken: true,
          request: AuthFormSucceeded(),
          verify: AuthFormSucceeded(),
        ),
      ],
      verify: (_) =>
          verify(() => verifyOtp(email: _email, code: '012345')).called(1),
    );

    for (final code in ['12345', '1234567', '12a456', '']) {
      blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
        '"$code" is not a six-digit code and is not sent',
        build: build,
        seed: () => _sent,
        act: (c) => c.verifyCode(code),
        expect: () => const <PasswordRecoveryState>[],
      );
    }

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a response without a token is a failure, and earns no token',
      setUp: () =>
          when(
            () => verifyOtp(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenAnswer(
            (_) async => const Left(
              ServerFailure(message: 'no token', code: 'missing_reset_token'),
            ),
          ),
      build: build,
      seed: () => _sent,
      act: (c) => c.verifyCode('123456'),
      verify: (c) {
        expect(c.state.verify, isA<AuthFormFailed>());
        expect(c.state.hasResetToken, isFalse);
      },
    );

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'a double submit verifies once',
      setUp: () {
        final gate = Completer<Either<Failure, String>>();
        when(
          () => verifyOtp(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) => gate.future);
        Future<void>.delayed(
          Duration.zero,
          () => gate.complete(const Right('t')),
        );
      },
      build: build,
      seed: () => _sent,
      act: (c) => Future.wait([c.verifyCode('123456'), c.verifyCode('123456')]),
      verify: (_) => verify(
        () => verifyOtp(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).called(1),
    );
  });

  group('the reset token is temporary', () {
    test('a verified code earns a token the flow can hand on', () async {
      final cubit = PasswordRecoveryCubit(forget, verifyOtp, initial: _sent);
      await cubit.verifyCode('012345');
      expect(cubit.resetToken, 'tok-1');
      await cubit.close();
    });

    blocTest<PasswordRecoveryCubit, PasswordRecoveryState>(
      'clearResetToken drops it and keeps the email',
      build: () =>
          recoveryAt(forgetPassword: forget, verifyResetOtp: verifyOtp),
      act: (c) => c.clearResetToken(),
      verify: (c) {
        expect(c.state.hasResetToken, isFalse);
        expect(c.resetToken, isNull);
        expect(c.state.email, _email);
      },
    );

    test('closing the flow drops it', () async {
      final cubit = recoveryAt(
        forgetPassword: forget,
        verifyResetOtp: verifyOtp,
      );
      expect(cubit.resetToken, 'verified-token');
      await cubit.close();
      expect(cubit.resetToken, isNull);
    });

    test('the state never prints the email or the token', () {
      final text = recoveryAt(resetToken: 'secret-token').state.toString();
      expect(text, isNot(contains('secret-token')));
      expect(text, isNot(contains(_email)));
      expect(text, contains('hasResetToken: true'));
    });
  });
}
