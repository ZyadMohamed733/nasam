/// Wire shape of the `currency` object nested under `user.account`.
class CurrencyModel {
  const CurrencyModel({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.symbol,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
    id: json['id'] as String,
    code: json['code'] as String,
    nameEn: json['nameEn'] as String,
    nameAr: json['nameAr'] as String,
    symbol: json['symbol'] as String,
  );

  final String id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String symbol;

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'symbol': symbol,
  };
}
