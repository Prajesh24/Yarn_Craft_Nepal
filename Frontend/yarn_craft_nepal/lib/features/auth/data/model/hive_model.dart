import 'package:hive/hive.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';

/// Hive type ID — must be unique across the whole app.
/// Change only if you add new models with conflicting IDs.
@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password; // stored as hashed value from server

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? role;

  AuthHiveModel({
    this.authId,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
    this.role = 'user',
  });

  // Entity

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      name: name,
      email: email,
      password: password,
      imageUrl: imageUrl,
      role: role,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      imageUrl: entity.imageUrl,
      role: entity.role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
