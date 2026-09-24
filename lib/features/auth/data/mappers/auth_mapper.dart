import '../../domain/entities/account_entity.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/currency_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_type.dart';
import '../models/account_model.dart';
import '../models/currency_model.dart';
import '../models/user_model.dart';

abstract final class AuthMapper {
  static CurrencyEntity currencyToEntity(CurrencyModel model) => CurrencyEntity(
    id: model.id,
    code: model.code,
    nameEn: model.nameEn,
    nameAr: model.nameAr,
    symbol: model.symbol,
  );

  static AccountEntity accountToEntity(AccountModel model) => AccountEntity(
    id: model.id,
    type: model.type,
    nameEn: model.nameEn,
    nameAr: model.nameAr,
    email: model.email,
    phoneNumber1: model.phoneNumber1,
    phoneNumber2: model.phoneNumber2,
    fax: model.fax,
    currency: currencyToEntity(model.currency),
  );

  /// `nameEn`/`nameAr` nulls stay null here -- deciding what to show when
  /// both are absent (fall back to `username`) is a presentation concern,
  /// not something this mapper should bake in.
  static UserEntity userToEntity(UserModel model) => UserEntity(
    id: model.id,
    username: model.username,
    email: model.email,
    nameEn: model.nameEn,
    nameAr: model.nameAr,
    account: model.account == null ? null : accountToEntity(model.account!),
    type: _userTypeFromWire(model.type),
    permissions: model.permissions,
  );

  /// [refreshToken] is threaded in separately rather than read off
  /// [AuthSessionModel] because the model's may be absent -- the repository
  /// resolves it (falling back to the stored one) and this mapper stays the
  /// single place that assembles the final, always-non-null entity.
  static AuthSessionEntity sessionToEntity({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) => AuthSessionEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: userToEntity(user),
  );

  static UserType _userTypeFromWire(String value) => switch (value) {
    'ADMIN' => UserType.admin,
    'EMPLOYEE' => UserType.employee,
    'CLIENT_ADMIN' => UserType.clientAdmin,
    'CLIENT_EMPLOYEE' => UserType.clientEmployee,
    // A user type the docs didn't enumerate is a server/client contract
    // change, not a value the UI has any sensible label for -- fail loudly
    // rather than silently mislabel someone's access level.
    _ => throw FormatException('Unknown user type from API: "$value"'),
  };
}
