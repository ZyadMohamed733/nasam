import 'account_model.dart';

/// Wire shape of the `user` object returned by login (non-2FA),
/// verify-otp, and refresh-access-token.
///
/// `account` is nullable: an ADMIN-type internal-staff user (confirmed
/// against the real dev API, not just the docs) has no company/individual
/// account attached and the API sends `account: null`.
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.nameEn,
    required this.nameAr,
    required this.account,
    required this.type,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    nameEn: json['nameEn'] as String?,
    nameAr: json['nameAr'] as String?,
    account: json['account'] == null
        ? null
        : AccountModel.fromJson(json['account'] as Map<String, dynamic>),
    // Kept as the raw wire string here too -- see UserType for why the
    // enum conversion happens in the mapper, not this model.
    type: json['type'] as String,
    permissions: (json['permissions'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
  );

  final String id;
  final String username;
  final String email;
  final String? nameEn;
  final String? nameAr;
  final AccountModel? account;
  final String type;
  final List<String> permissions;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'account': account?.toJson(),
    'type': type,
    'permissions': permissions,
  };
}
