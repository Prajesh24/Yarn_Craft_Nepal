import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/data/repository_impl/auth_repository_implementation.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';
import 'package:yarn_craft_nepal/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// Params

class RegisterUsecaseParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterUsecaseParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

// Provider

final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

// Use case

class RegisterUseCase
    implements UseCaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  const RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    if (kDebugMode) {
      print('UseCase - params.confirmPassword: ${params.confirmPassword}');
    }

    final entity = AuthEntity(
      name: params.name,
      email: params.email,
      password: params.password,
      imageUrl: null,
      role: 'user',
    );

    if (kDebugMode) {
      print('UseCase - passing confirmPassword: ${params.confirmPassword}');
    }

    return _authRepository.register(
      entity,
      confirmPassword: params.confirmPassword,
    );
  }
}
