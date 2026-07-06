import 'package:json_annotation/json_annotation.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(
    name: '_id',
    includeIfNull: false,
  ) // MongoDB _id — not sent on create
  final String? id;

  final String name;
  final String email;

  @JsonKey(includeIfNull: false)
  final String? password;

  @JsonKey(name: 'imageUrl', includeIfNull: false)
  final String? imageUrl;

  final String? role;

  const AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
    this.role = 'user',
  });

  // JSON

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  // Entity

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      name: name,
      email: email,
      password: password,
      imageUrl: imageUrl,
      role: role,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      imageUrl: entity.imageUrl,
      role: entity.role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
