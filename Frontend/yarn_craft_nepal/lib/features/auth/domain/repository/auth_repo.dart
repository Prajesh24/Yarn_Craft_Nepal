import 'package:dartz/dartz.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';
import '../../../../core/error/failures.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> login(String email, String password);

  Future<Either<Failure, bool>> register(
    AuthEntity entity, {
    String? confirmPassword,
  });

  /// Sends a password-reset link/OTP to [emailOrPhone].
  Future<Either<Failure, bool>> forgotPassword(String emailOrPhone);

  /// Resets the password using the [token] received via email/SMS.
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
}
