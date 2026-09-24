import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/constants/app_strings.dart';
import 'package:nasam/core/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_helper.dart';

void main() {
  late MockFlutterSecureStorage keychain;
  late SecureStorageService service;

  void verifyReads(int times) => times == 0
      ? verifyNever(() => keychain.read(key: AppStrings.keyAccessToken))
      : verify(
          () => keychain.read(key: AppStrings.keyAccessToken),
        ).called(times);

  setUp(() {
    keychain = MockFlutterSecureStorage();
    when(
      () => keychain.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'stored-access');
    when(
      () => keychain.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => keychain.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    service = SecureStorageService(keychain);
  });

  group('access token cache', () {
    // The interceptor asks on every request; a keychain read each time is a
    // platform-channel round trip per API call.
    test('reads the keychain once, however often it is asked', () async {
      for (var i = 0; i < 5; i++) {
        expect(await service.getAccessToken(), 'stored-access');
      }
      verifyReads(1);
    });

    test('callers arriving together share one read', () async {
      final read = Completer<String?>();
      when(
        () => keychain.read(key: AppStrings.keyAccessToken),
      ).thenAnswer((_) => read.future);

      final all = Future.wait([
        for (var i = 0; i < 3; i++) service.getAccessToken(),
      ]);
      read.complete('stored-access');

      expect(await all, ['stored-access', 'stored-access', 'stored-access']);
      verifyReads(1);
    });

    test('a save writes through and is served without a read', () async {
      await service.saveAccessToken('fresh');

      expect(await service.getAccessToken(), 'fresh');
      verify(
        () => keychain.write(key: AppStrings.keyAccessToken, value: 'fresh'),
      ).called(1);
      verifyReads(0);
    });

    test('a save that lands during a read is not overwritten by it', () async {
      final read = Completer<String?>();
      when(
        () => keychain.read(key: AppStrings.keyAccessToken),
      ).thenAnswer((_) => read.future);

      final pending = service.getAccessToken();
      await service.saveAccessToken('fresh');
      read.complete('stale');

      expect(await pending, 'fresh');
      expect(await service.getAccessToken(), 'fresh');
    });

    test('a failed read is not remembered', () async {
      var calls = 0;
      when(() => keychain.read(key: AppStrings.keyAccessToken)).thenAnswer((
        _,
      ) async {
        if (calls++ == 0) throw StateError('keychain locked');
        return 'stored-access';
      });

      await expectLater(service.getAccessToken(), throwsStateError);
      expect(await service.getAccessToken(), 'stored-access');
      verifyReads(2);
    });
  });

  group('session version', () {
    test('every clear moves it on', () async {
      final before = service.sessionVersion;
      await service.clearAuth();
      await service.clearAuth();
      expect(service.sessionVersion, before + 2);
    });

    // A save issued just before a sign-out must not leave the token in the
    // cache after the sign-out has cleared the keychain.
    test(
      'a save that lands after a clear does not repopulate the cache',
      () async {
        final write = Completer<void>();
        when(
          () => keychain.write(
            key: AppStrings.keyAccessToken,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) => write.future);

        final saving = service.saveAccessToken('late');
        await service.clearAuth();
        write.complete();
        await saving;

        expect(await service.getAccessToken(), isNull);
        expect(service.hasAccessToken, isFalse);
      },
    );
  });

  group('clearAuth', () {
    test('deletes the auth keys, and only those', () async {
      await service.clearAuth();

      for (final key in [
        AppStrings.keyAccessToken,
        AppStrings.keyRefreshToken,
        AppStrings.keyUserData,
      ]) {
        verify(() => keychain.delete(key: key)).called(1);
      }
      verifyNoMoreInteractions(keychain);
      verifyNever(() => keychain.deleteAll());
    });

    test('drops the cached token, without reading it back', () async {
      await service.saveAccessToken('fresh');
      await service.clearAuth();

      expect(await service.getAccessToken(), isNull);
      expect(service.hasAccessToken, isFalse);
      verifyReads(0);
    });

    test('drops the cached token even if the keychain delete fails', () async {
      await service.saveAccessToken('fresh');
      when(
        () => keychain.delete(key: any(named: 'key')),
      ).thenThrow(StateError('keychain'));

      await expectLater(service.clearAuth(), throwsStateError);
      expect(await service.getAccessToken(), isNull);
    });
  });

  // iOS keeps keychain items across an uninstall; the reinstalled app must
  // not wake up as whoever was signed in before.
  group('open: the reinstall wipe', () {
    test(
      'first launch clears the auth keys before anything reads them',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final opened = await SecureStorageService.open(keychain, prefs);

        verify(() => keychain.delete(key: AppStrings.keyAccessToken)).called(1);
        verify(
          () => keychain.delete(key: AppStrings.keyRefreshToken),
        ).called(1);
        verify(() => keychain.delete(key: AppStrings.keyUserData)).called(1);
        expect(prefs.getBool(AppStrings.keyAuthStorageInitialised), isTrue);
        // The wipe settles the cache, so the old token is never read at all —
        // not by open, and not by the first request afterwards.
        expect(await opened.getAccessToken(), isNull);
        expect(opened.hasAccessToken, isFalse);
        verifyReads(0);
      },
    );

    test('later launches leave the session alone and warm the cache', () async {
      SharedPreferences.setMockInitialValues({
        AppStrings.keyAuthStorageInitialised: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final opened = await SecureStorageService.open(keychain, prefs);

      verifyNever(() => keychain.delete(key: any(named: 'key')));
      expect(opened.hasAccessToken, isTrue);
      expect(await opened.getAccessToken(), 'stored-access');
      verifyReads(1);
    });

    test(
      'a failed wipe does not block startup and is retried next launch',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        when(
          () => keychain.delete(key: any(named: 'key')),
        ).thenThrow(StateError('keychain unavailable'));

        final opened = await SecureStorageService.open(keychain, prefs);

        expect(opened, isA<SecureStorageService>());
        expect(prefs.getBool(AppStrings.keyAuthStorageInitialised), isNull);
      },
    );
  });
}
