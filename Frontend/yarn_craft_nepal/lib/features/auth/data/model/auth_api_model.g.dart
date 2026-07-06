// GENERATED CODE - DO NOT MODIFY BY HAND
//
// To regenerate run:
// dart run build_runner build --delete-conflicting-outputs

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
  id: json['_id'] as String?,
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
  imageUrl: json['imageUrl'] as String?,
  role: json['role'] as String? ?? 'user',
);

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) val[key] = value;
  }

  writeNotNull('_id', instance.id);
  val['name'] = instance.name;
  val['email'] = instance.email;
  writeNotNull('password', instance.password);
  writeNotNull('imageUrl', instance.imageUrl);
  val['role'] = instance.role;

  return val;
}
