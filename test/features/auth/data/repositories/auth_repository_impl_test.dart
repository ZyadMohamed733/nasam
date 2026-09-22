import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nasam/features/auth/data/models/account_model.dart';
import 'package:nasam/features/auth/data/models/auth_session_model.dart';
import 'package:nasam/features/auth/data/models/currency_model.dart';
import 'package:nasam/features/auth/data/models/user_model.dart';
import 'package:nasam/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nasam/features/auth/domain/entities/login_result.dart';

import '../../../../helpers/mock_helper.dart';

class _RemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late _RemoteDataSource remote;
  late MockSecureStorageService storage;
  late AuthRepositoryImpl repository;

  final currency = const CurrencyModel(
    id: 'currency-1',
    code: 'SAR',
    nameEn: 'Saudi Riyal',
    nameAr: 'ريال سعودي',
    symbol: '﷼',
  );
  final account = AccountModel(
    id: 'account-1',
    type: 'COMPANY',
    nameEn: 'Nasam',
    nameAr: 'نسم',
    email: 'account@nasam.sa',
    phoneNumber1: '+966500000000',
    phoneNumber2: null,
    fax: null,
    currency: currency,
  );
  UserModel user() => UserModel(
    id: 'user-1',
    username: 'john.doe',
    email: 'john.doe@nasam.sa',
    nameEn: 'John Doe',
    nameAr: null,
    account: account,
    type: 'ADMIN',
    permissions: const ['core.user_management.view'],
  );

  setUp(() {
    remote = _RemoteDataSource();
    storage = MockSecureStorageService();
    repository = AuthRepositoryImpl(remote, storage);

    when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => storage.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => storage.saveUser(any())).thenAnswer((_) async {});
    when(() => storage.clearAll()).thenAnswer((_) async {});
  });

  group('login', () {
    test('a 2FA account yields LoginRequiresOtp without persisting anything', () async {
      when(
        () => remote.login(username: 'john.doe', password: 'S3curePass!'),
      ).thenAnswer((_) async => null);

      final result = await repository.login(
        username: 'john.doe',
        password: 'S3curePass!',
      );

      expect(result, Right<Failure, LoginResult>(const LoginRequiresOtp('john.doe')));
      verifyNever(() => storage.saveAccessToken(any()));
      verifyNever(() => storage.saveUser(any()));
    });

    test('a non-2FA account persists the session and yields LoginSucceeded', () async {
      when(
        () => remote.login(username: 'john.doe', password: 'S3curePass!'),
      ).thenAnswer(
        (_) async => AuthSessionModel(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
          user: user(),
        ),
      );

      final result = await repository.login(
        username: 'john.doe',
        password: 'S3curePass!',
      );

      expect(result.isRight(), isTrue);
      final session = (result as Right<Failure, LoginResult>).value
          as LoginSucceeded;
      expect(session.session.accessToken, 'access-1');
      expect(session.session.refreshToken, 'refresh-1');
      expect(session.session.user.username, 'john.doe');
      verify(() => storage.saveAccessToken('access-1')).called(1);
      verify(() => storage.saveRefreshToken('refresh-1')).called(1);
      verify(() => storage.saveUser(any())).called(1);
    });

    test('an AppException from the datasource maps to a Failure', () async {
      when(
        () => remote.login(username: 'john.doe', password: 'wrong'),
      ).thenThrow(
        const AuthException(message: 'Invalid credentials.', code: '401'),
      );

      final result = await repository.login(
        username: 'john.doe',
        password: 'wrong',
      );

      expect(result, isA<Left<Failure, LoginResult>>());
      expect(
        (result as Left<Failure, LoginResult>).value,
        isA<AuthFailure>(),
      );
    });
  });

  group('logout', () {
    test('clears local storage even when the server call throws', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
      when(() => remote.logout(any())).thenThrow(
        const ServerException(message: 'down', code: '500'),
      );

      final result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => storage.clearAll()).called(1);
    });

    test('clears local storage when the server call succeeds', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh-1');
      when(() => remote.logout(any())).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => remote.logout('refresh-1')).called(1);
      verify(() => storage.clearAll()).called(1);
    });
  });
}
