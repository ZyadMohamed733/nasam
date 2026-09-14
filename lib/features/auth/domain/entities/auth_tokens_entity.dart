import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens_entity.freezed.dart';

/// The pair a successful sign-in yields.
///
/// Deliberately has no `toString` override beyond Freezed's: these are bearer
/// credentials, and the logging interceptor already redacts them in transit.
@freezed
abstract class AuthTokensEntity with _$AuthTokensEntity {
  const factory AuthTokensEntity({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokensEntity;
}
