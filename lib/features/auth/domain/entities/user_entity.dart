import 'account_entity.dart';
import 'user_type.dart';

/// The signed-in user, as returned by login / verify-otp / refresh.
///
/// `nameEn`/`nameAr` are nullable here exactly as the wire payload is --
/// deciding what to show when both are null (fall back to [username]) is a
/// presentation concern, not something this entity or its mapper should bake
/// in. `account` is nullable too: an ADMIN-type internal-staff user has none
/// (confirmed against the real dev API -- not just the docs, which showed
/// only a populated example).
class UserEntity {
  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.nameEn,
    required this.nameAr,
    required this.account,
    required this.type,
    required this.permissions,
  });

  final String id;
  final String username;
  final String email;
  final String? nameEn;
  final String? nameAr;
  final AccountEntity? account;
  final UserType type;

  /// Flat expression strings (e.g.
  /// `"core.user_management.user_management_list.view"`). The only
  /// authorization signal -- [type] is for display/labelling only.
  final List<String> permissions;

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          nameEn == other.nameEn &&
          nameAr == other.nameAr &&
          account == other.account &&
          type == other.type &&
          _listEquals(permissions, other.permissions);

  @override
  int get hashCode => Object.hash(
    id,
    username,
    email,
    nameEn,
    nameAr,
    account,
    type,
    Object.hashAll(permissions),
  );

  @override
  String toString() => 'UserEntity(id: $id, username: $username)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
