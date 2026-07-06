import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/data/repository_impl/auth_repository_implementation.dart';
import 'package:yarn_craft_nepal/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// Params

class ForgotPasswordParams extends Equatable {
  final String emailOrPhone;

  const ForgotPasswordParams({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

// Provider

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUsecase(authRepository: authRepository);
});

// Use case

class ForgotPasswordUsecase
    implements UseCaseWithParams<bool, ForgotPasswordParams> {
  final IAuthRepository _authRepository;

  const ForgotPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordParams params) {
    return _authRepository.forgotPassword(params.emailOrPhone);
  }
}
