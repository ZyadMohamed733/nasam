import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/domain/entities/account_entity.dart';
import 'package:nasam/features/auth/domain/entities/auth_session_entity.dart';
import 'package:nasam/features/auth/domain/entities/currency_entity.dart';
import 'package:nasam/features/auth/domain/entities/login_result.dart';
import 'package:nasam/features/auth/domain/entities/user_entity.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';
import 'package:nasam/features/auth/domain/repositories/auth_repository.dart';
import 'package:nasam/features/auth/domain/usecases/login_usecase.dart';
import 'package:nasam/features/auth/presentation/cubit/auth_form_status.dart';
import 'package:nasam/features/auth/presentation/cubit/login_cubit.dart';

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
  late LoginCubit cubit;

  setUp(() {
    repository = _Repository();
    cubit = LoginCubit(LoginUseCase(repository));
  });

  tearDown(() => cubit.close());

  blocTest<LoginCubit, AuthFormStatus>(
    'a non-2FA login emits submitting then succeeded',
    build: () {
      when(
        () => repository.login(username: 'john.doe', password: 'S3curePass!'),
      ).thenAnswer((_) async => Right(LoginSucceeded(_session())));
      return cubit;
    },
    act: (c) => c.submit(username: 'john.doe', password: 'S3curePass!'),
    expect: () => [const AuthFormSubmitting(), const AuthFormSucceeded()],
  );

  blocTest<LoginCubit, AuthFormStatus>(
    'a 2FA-enabled account emits LoginNeedsOtp with the username',
    build: () {
      when(
        () => repository.login(username: 'john.doe', password: 'S3curePass!'),
      ).thenAnswer((_) async => const Right(LoginRequiresOtp('john.doe')));
      return cubit;
    },
    act: (c) => c.submit(username: 'john.doe', password: 'S3curePass!'),
    expect: () => [const AuthFormSubmitting(), const LoginNeedsOtp('john.doe')],
  );

  blocTest<LoginCubit, AuthFormStatus>(
    'bad credentials emit AuthFormFailed with the repository failure',
    build: () {
      when(
        () => repository.login(username: 'john.doe', password: 'wrong'),
      ).thenAnswer(
        (_) async => const Left(
          AuthFailure(message: 'Invalid username or password.', code: '401'),
        ),
      );
      return cubit;
    },
    act: (c) => c.submit(username: 'john.doe', password: 'wrong'),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormFailed(
        AuthFailure(message: 'Invalid username or password.', code: '401'),
      ),
    ],
  );

  blocTest<LoginCubit, AuthFormStatus>(
    'trims the username before calling the usecase',
    build: () {
      when(
        () => repository.login(username: 'john.doe', password: 'S3curePass!'),
      ).thenAnswer((_) async => const Right(LoginRequiresOtp('john.doe')));
      return cubit;
    },
    act: (c) => c.submit(username: '  john.doe  ', password: 'S3curePass!'),
    verify: (_) => verify(
      () => repository.login(username: 'john.doe', password: 'S3curePass!'),
    ).called(1),
  );
}
