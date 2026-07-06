import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/data/repository_impl/auth_repository_implementation.dart';
import 'package:yarn_craft_nepal/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// Params

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

// Provider

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository: authRepository);
});

// Use case

class ResetPasswordUsecase
    implements UseCaseWithParams<bool, ResetPasswordParams> {
  final IAuthRepository _authRepository;

  const ResetPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
