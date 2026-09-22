import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/entities/account_entity.dart';
import 'package:nasam/features/auth/domain/entities/auth_session_entity.dart';
import 'package:nasam/features/auth/domain/entities/currency_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:nasam/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/auth_form_status.dart';
import 'package:nasam/features/auth/presentation/cubit/otp_cubit.dart';

class _Repository extends Mock implements AuthRepository {}

AuthSessionEntity _session() => const AuthSessionEntity(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: UserEntity(
    id: 'user-1',
    username: 'john.doe',
    email: 'john.doe@nasam.sa',
    nameEn: 'John Doe',
    nameAr: null,
    account: AccountEntity(
      id: 'account-1',
      type: 'COMPANY',
      nameEn: 'Nasam',
      nameAr: 'نسم',
      email: 'account@nasam.sa',
      phoneNumber1: '+966500000000',
      phoneNumber2: null,
      fax: null,
      currency: CurrencyEntity(
        id: 'currency-1',
        code: 'SAR',
        nameEn: 'Saudi Riyal',
        nameAr: 'ريال سعودي',
        symbol: '﷼',
      ),
    ),
    type: UserType.admin,
    permissions: [],
  ),
);

void main() {
  late _Repository repository;
  late OtpCubit cubit;

  setUp(() {
    repository = _Repository();
    cubit = OtpCubit(
      VerifyOtpUseCase(repository),
      ResendOtpUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  blocTest<OtpCubit, AuthFormStatus>(
    'a correct code emits submitting then succeeded, nothing further to carry',
    build: () {
      when(
        () => repository.verifyOtp(username: 'john.doe', code: '123456'),
      ).thenAnswer((_) async => Right(_session()));
      return cubit;
    },
    act: (c) => c.submit(username: 'john.doe', code: '123456'),
    expect: () => [const AuthFormSubmitting(), const AuthFormSucceeded()],
  );

  blocTest<OtpCubit, AuthFormStatus>(
    'an invalid code emits AuthFormFailed with the repository failure',
    build: () {
      when(
        () => repository.verifyOtp(username: 'john.doe', code: '000000'),
      ).thenAnswer(
        (_) async => const Left(
          AuthFailure(message: 'That code is invalid.', code: '401'),
        ),
      );
      return cubit;
    },
    act: (c) => c.submit(username: 'john.doe', code: '000000'),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormFailed(
        AuthFailure(message: 'That code is invalid.', code: '401'),
      ),
    ],
  );

  blocTest<OtpCubit, AuthFormStatus>(
    'trims the username before calling verifyOtp',
    build: () {
      when(
        () => repository.verifyOtp(username: 'john.doe', code: '123456'),
      ).thenAnswer((_) async => Right(_session()));
      return cubit;
    },
    act: (c) => c.submit(username: '  john.doe  ', code: '123456'),
    verify: (_) => verify(
      () => repository.verifyOtp(username: 'john.doe', code: '123456'),
    ).called(1),
  );

  blocTest<OtpCubit, AuthFormStatus>(
    'resend does not move the form into submitting',
    build: () {
      when(
        () => repository.resendOtp('john.doe'),
      ).thenAnswer((_) async => const Right(unit));
      return cubit;
    },
    act: (c) => c.resend('john.doe'),
    expect: () => <AuthFormStatus>[],
    verify: (_) => verify(() => repository.resendOtp('john.doe')).called(1),
  );
}
