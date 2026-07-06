import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/data/repository_impl/auth_repository_implementation.dart';
import 'package:yarn_craft_nepal/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

final logoutUsecaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(authRepository: ref.watch(authRepositoryProvider));
});

class LogoutUseCase implements UseCaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  const LogoutUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}
