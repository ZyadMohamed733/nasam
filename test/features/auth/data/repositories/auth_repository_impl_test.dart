import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/auth/auth_session_notifier.dart';
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
  late AuthSessionNotifier notifier;

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
    when(() => storage.hasAccessToken).thenReturn(false);
    when(() => storage.sessionVersion).thenReturn(0);
    notifier = AuthSessionNotifier(storage);
    repository = AuthRepositoryImpl(remote, storage, notifier);

    when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => storage.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => storage.saveUser(any())).thenAnswer((_) async {});
    when(() => storage.clearAuth()).thenAnswer((_) async {});
  });

  group('login', () {
    test(
      'a 2FA account yields LoginRequiresOtp without persisting anything',
      () async {
        when(
          () => remote.login(username: 'john.doe', password: 'S3curePass!'),
        ).thenAnswer((_) async => null);

        final result = await repository.login(
          username: 'john.doe',
          password: 'S3curePass!',
        );

        expect(
          result,
          Right<Failure, LoginResult>(const LoginRequiresOtp('john.doe')),
        );
        verifyNever(() => storage.saveAccessToken(any()));
        verifyNever(() => storage.saveUser(any()));
      },
    );

    test(
      'a non-2FA account persists the session and yields LoginSucceeded',
      () async {
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
        final session =
            (result as Right<Failure, LoginResult>).value as LoginSucceeded;
        expect(session.session.accessToken, 'access-1');
        expect(session.session.refreshToken, 'refresh-1');
        expect(session.session.user.username, 'john.doe');
        verify(() => storage.saveAccessToken('access-1')).called(1);
        verify(() => storage.saveRefreshToken('refresh-1')).called(1);
        verify(() => storage.saveUser(any())).called(1);
        // What moves the router on from the login screen.
        expect(notifier.value, AuthSessionStatus.signedIn);
      },
    );

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
      expect((result as Left<Failure, LoginResult>).value, isA<AuthFailure>());
    });
  });

  group('logout', () {
    test('clears local storage even when the server call throws', () async {
      when(
        () => storage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-1');
      when(
        () => remote.logout(any()),
      ).thenThrow(const ServerException(message: 'down', code: '500'));

      final result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => storage.clearAuth()).called(1);
      expect(notifier.value, AuthSessionStatus.signedOut);
      expect(notifier.endedByUser, isTrue);
    });

    // The previous version caught only AppException, and cleared storage
    // after the try: anything else skipped the clear and left the user
    // signed in on the device while the app believed they had left.
    test(
      'clears local storage when the server call throws anything at all',
      () async {
        notifier.signIn();
        when(
          () => storage.getRefreshToken(),
        ).thenAnswer((_) async => 'refresh-1');
        when(
          () => remote.logout(any()),
        ).thenThrow(StateError('not an AppException'));

        final result = await repository.logout();

        verify(() => storage.clearAuth()).called(1);
        expect(notifier.value, AuthSessionStatus.signedOut);
        expect(
          result.isLeft(),
          isTrue,
          reason: 'the unexpected error surfaces',
        );
      },
    );

    test('clears local storage when even reading the token throws', () async {
      notifier.signIn();
      when(() => storage.getRefreshToken()).thenThrow(StateError('keychain'));

      await repository.logout();

      verify(() => storage.clearAuth()).called(1);
      verifyNever(() => remote.logout(any()));
      expect(notifier.value, AuthSessionStatus.signedOut);
    });

    test('tells the router even when clearing the keychain fails', () async {
      notifier.signIn();
      when(
        () => storage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-1');
      when(() => remote.logout(any())).thenAnswer((_) async {});
      when(() => storage.clearAuth()).thenThrow(StateError('keychain'));

      final result = await repository.logout();

      expect(result.isLeft(), isTrue);
      expect(notifier.value, AuthSessionStatus.signedOut);
    });

    test('clears local storage when the server call succeeds', () async {
      when(
        () => storage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-1');
      when(() => remote.logout(any())).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => remote.logout('refresh-1')).called(1);
      verify(() => storage.clearAuth()).called(1);
    });
  });

  group('currentUser', () {
    test('reads the profile stored at sign-in', () async {
      when(
        () => storage.getUser(),
      ).thenAnswer((_) async => jsonEncode(user().toJson()));

      final result = await repository.currentUser();

      final found = result.getOrElse(() => throw StateError('failed'));
      expect(found?.username, 'john.doe');
      expect(found?.nameEn, 'John Doe');
    });

    test('is null when nobody is signed in', () async {
      when(() => storage.getUser()).thenAnswer((_) async => null);
      expect(await repository.currentUser(), const Right<Failure, Null>(null));
    });

    test('an unreadable stored profile is a CacheFailure', () async {
      when(() => storage.getUser()).thenAnswer((_) async => '{not json');
      final result = await repository.currentUser();
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  group('verifyResetOtp', () {
    test('hands back the reset token and stores nothing', () async {
      when(
        () => remote.verifyResetOtp(email: 'a@b.c', code: '012345'),
      ).thenAnswer((_) async => 'tok-1');

      final result = await repository.verifyResetOtp(
        email: 'a@b.c',
        code: '012345',
      );

      expect(result, const Right<Failure, String>('tok-1'));
      // A reset token is not a session: nothing is persisted.
      verifyNever(() => storage.saveAccessToken(any()));
      verifyNever(() => storage.saveRefreshToken(any()));
      expect(notifier.value, AuthSessionStatus.signedOut);
    });

    test('a response without a token is a failure', () async {
      when(
        () => remote.verifyResetOtp(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenThrow(
        const ServerException(message: 'no token', code: 'missing_reset_token'),
      );

      final result = await repository.verifyResetOtp(email: 'a@b.c', code: '1');

      expect(
        result.fold((f) => f, (_) => null),
        isA<ServerFailure>().having(
          (f) => f.code,
          'code',
          'missing_reset_token',
        ),
      );
    });
  });
}
