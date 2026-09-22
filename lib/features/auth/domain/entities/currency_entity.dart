/// The currency an [AccountEntity] bills and reports in.
///
/// Hand-written rather than `@freezed`: this feature slice is built in an
/// environment with no `build_runner` available, so generated `.freezed.dart`
/// parts cannot be produced here. Equality/hashCode are implemented by hand
/// to keep this usable as a value type in tests and cubit state.
class CurrencyEntity {
  const CurrencyEntity({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.symbol,
  });

  final String id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String symbol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          nameEn == other.nameEn &&
          nameAr == other.nameAr &&
          symbol == other.symbol;

  @override
  int get hashCode => Object.hash(id, code, nameEn, nameAr, symbol);

  @override
  String toString() => 'CurrencyEntity(id: $id, code: $code)';
}
