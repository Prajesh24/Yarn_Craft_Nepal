import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String name;
  final String email;
  final String? password;
  final String? imageUrl;
  final String? role;

  const AuthEntity({
    this.authId,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
    this.role = 'user',
  });

  String get firstName => name.split(' ').first;
  bool get isAdmin => role == 'admin';

  AuthEntity copyWith({
    String? authId,
    String? name,
    String? email,
    String? password,
    String? imageUrl,
    String? role,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [authId, name, email, password, imageUrl, role];
}
