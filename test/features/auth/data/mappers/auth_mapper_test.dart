import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/auth/data/mappers/auth_mapper.dart';
import 'package:nasam/features/auth/data/models/account_model.dart';
import 'package:nasam/features/auth/data/models/currency_model.dart';
import 'package:nasam/features/auth/data/models/user_model.dart';
import 'package:nasam/features/auth/domain/entities/user_type.dart';

void main() {
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

  group('AuthMapper.userToEntity', () {
    test('maps a populated account to a non-null AccountEntity', () {
      final model = UserModel(
        id: 'user-1',
        username: 'john.doe',
        email: 'john.doe@nasam.sa',
        nameEn: 'John Doe',
        nameAr: null,
        account: account,
        type: 'CLIENT_ADMIN',
        permissions: const ['core.user_management.view'],
      );

      final entity = AuthMapper.userToEntity(model);

      expect(entity.account, isNotNull);
      expect(entity.account!.id, 'account-1');
      expect(entity.type, UserType.clientAdmin);
    });

    // Regression test for the real dev API returning `account: null` for
    // internal-staff (ADMIN) users -- the docs' single example showed a
    // populated account, which previously led this mapper to force-cast a
    // null value and crash right after a successful login.
    test('maps a null account to a null AccountEntity without throwing', () {
      final model = UserModel(
        id: 'user-2',
        username: 'saudi_tracking_admin',
        email: 'admin@nasam.sa',
        nameEn: null,
        nameAr: null,
        account: null,
        type: 'ADMIN',
        permissions: const ['core.user_management.view'],
      );

      final entity = AuthMapper.userToEntity(model);

      expect(entity.account, isNull);
      expect(entity.type, UserType.admin);
    });
  });

  group('UserModel.fromJson', () {
    test(
      'parses account: null exactly as the real API returns for ADMIN users',
      () {
        final json = {
          'id': 'user-2',
          'username': 'saudi_tracking_admin',
          'email': 'admin@nasam.sa',
          'nameEn': null,
          'nameAr': null,
          'account': null,
          'type': 'ADMIN',
          'permissions': <String>['core.user_management.view'],
        };

        final model = UserModel.fromJson(json);

        expect(model.account, isNull);
      },
    );

    test('parses a populated account object', () {
      final json = {
        'id': 'user-1',
        'username': 'john.doe',
        'email': 'john.doe@nasam.sa',
        'nameEn': 'John Doe',
        'nameAr': null,
        'account': account.toJson(),
        'type': 'CLIENT_ADMIN',
        'permissions': <String>['core.user_management.view'],
      };

      final model = UserModel.fromJson(json);

      expect(model.account, isNotNull);
      expect(model.account!.id, 'account-1');
    });
  });
}
