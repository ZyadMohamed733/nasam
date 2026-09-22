import 'currency_model.dart';

/// Wire shape of the `account` object nested under `user`.
class AccountModel {
  const AccountModel({
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

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    id: json['id'] as String,
    type: json['type'] as String,
    nameEn: json['nameEn'] as String,
    nameAr: json['nameAr'] as String,
    email: json['email'] as String,
    phoneNumber1: json['phoneNumber1'] as String,
    phoneNumber2: json['phoneNumber2'] as String?,
    fax: json['fax'] as String?,
    currency: CurrencyModel.fromJson(
      json['currency'] as Map<String, dynamic>,
    ),
  );

  final String id;
  final String type;
  final String nameEn;
  final String nameAr;
  final String email;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? fax;
  final CurrencyModel currency;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'email': email,
    'phoneNumber1': phoneNumber1,
    'phoneNumber2': phoneNumber2,
    'fax': fax,
    'currency': currency.toJson(),
  };
}
