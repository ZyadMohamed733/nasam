import 'currency_entity.dart';

/// The company/individual account a signed-in `UserEntity` belongs to.
///
/// `type` is kept as the raw wire string (`"COMPANY"`, ...) rather than an
/// enum: the API reference lists only that one example value, and turning it
/// into a closed enum here risks a crash on a legitimate value the docs
/// didn't happen to show, for a field the app does not currently branch on.
class AccountEntity {
  const AccountEntity({
    required this.id,
    required this.type,
    required this.nameEn,
    required this.nameAr,
    required this.email,
    required this.phoneNumber1,
    required this.phoneNumber2,
    required this.fax,
    required this.currency,
  });

  final String id;
  final String type;
  final String nameEn;
  final String nameAr;
  final String email;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? fax;
  final CurrencyEntity currency;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          nameEn == other.nameEn &&
          nameAr == other.nameAr &&
          email == other.email &&
          phoneNumber1 == other.phoneNumber1 &&
          phoneNumber2 == other.phoneNumber2 &&
          fax == other.fax &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    nameEn,
    nameAr,
    email,
    phoneNumber1,
    phoneNumber2,
    fax,
    currency,
  );

  @override
  String toString() => 'AccountEntity(id: $id, nameEn: $nameEn)';
}
