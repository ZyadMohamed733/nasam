import '../../domain/entities/auth_tokens_entity.dart';
import '../models/auth_tokens_model.dart';

abstract final class AuthMapper {
  static AuthTokensEntity toEntity(AuthTokensModel model) => AuthTokensEntity(
    accessToken: model.accessToken,
    refreshToken: model.refreshToken,
  );
}
