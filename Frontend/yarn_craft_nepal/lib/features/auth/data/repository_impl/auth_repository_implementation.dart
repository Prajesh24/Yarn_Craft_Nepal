import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:yarn_craft_nepal/features/auth/data/datasource/auth_datasource.dart';
import 'package:yarn_craft_nepal/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:yarn_craft_nepal/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/auth_api_model.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/hive_model.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';
import 'package:yarn_craft_nepal/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/network_info.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authLocalDatasource: ref.read(authLocalDataSourceProvider),
    authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  const AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  // LOGIN

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDatasource.loginUser(email, password);
        if (user == null) {
          return const Left(ServerFailure(message: 'Login failed.'));
        }
        return Right(user.toEntity());
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Login failed.',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.loginUser(email, password);
        if (user != null) return Right(user.toEntity());
        return const Left(
          LocalDatabaseFailue(message: 'Invalid email or password.'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailue(message: e.toString()));
      }
    }
  }

  // REGISTER

  @override
  Future<Either<Failure, bool>> register(
    AuthEntity entity, {
    String? confirmPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        final result = await _authRemoteDatasource.registerUser(
          apiModel,
          confirmPassword: confirmPassword,
        );
        if (result == null) {
          return const Left(ServerFailure(message: 'Registration failed.'));
        }
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Registration failed.',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = AuthHiveModel.fromEntity(entity);
        await _authLocalDatasource.registerUser(hiveModel);
        return const Right(true);
      } on HiveError catch (e) {
        return Left(LocalDatabaseFailue(message: e.message));
      } catch (e) {
        return Left(
          LocalDatabaseFailue(message: 'Unexpected error: ${e.toString()}'),
        );
      }
    }
  }

  // FORGOT PASSWORD

  @override
  Future<Either<Failure, bool>> forgotPassword(String emailOrPhone) async {
    // Forgot password always requires internet
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection. Please try again.'),
      );
    }

    try {
      final success = await _authRemoteDatasource.forgotPassword(emailOrPhone);

      if (success) return const Right(true);

      return const Left(ServerFailure(message: 'Failed to send reset link.'));
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Failed to send reset link.',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // RESET PASSWORD

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Reset password always requires internet
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection. Please try again.'),
      );
    }

    try {
      final success = await _authRemoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) return const Right(true);

      return const Left(ServerFailure(message: 'Password reset failed.'));
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Password reset failed.',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // CURRENT USER

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser('current_user_id');
      if (user != null) return Right(user.toEntity());
      return const Left(LocalDatabaseFailue(message: 'No current user found.'));
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }

  // LOGOUT

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logoutUser();
      if (result) return const Right(true);
      return const Left(LocalDatabaseFailue(message: 'Logout failed.'));
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }
}
