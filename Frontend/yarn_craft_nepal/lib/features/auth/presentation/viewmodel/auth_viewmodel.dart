import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';
import 'package:yarn_craft_nepal/features/auth/domain/usecase/forget_usecase.dart';
import 'package:yarn_craft_nepal/features/auth/domain/usecase/reset_usecase.dart';

import '../../../../core/services/hive/hive_service.dart';
import '../../../../core/services/storage/user_session.dart';
import '../../data/datasource/remote/auth_remote_datasource.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  // REGISTER

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RegisterUsecaseParams(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    final result = await ref.read(registerUsecaseProvider).call(params);

    result.fold(
      (failure) {
        if (kDebugMode) print('Register failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) async {
        if (kDebugMode) print('Register success');
        // Signal the UI to show the "Account Created" page…
        state = state.copyWith(status: AuthStatus.registered);
        // …then immediately log the new user in so they land on Home as
        // themselves (token + session + auth entity), not as a guest.
        await login(email: email, password: password);
      },
    );
  }

  // LOGIN

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = LoginUsecaseParams(email: email, password: password);
    final result = await ref.read(loginUsecaseProvider).call(params);

    result.fold(
      (failure) {
        if (kDebugMode) print('Login failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        if (kDebugMode) print('Login success: ${authEntity.name}');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // CONTINUE WITH REMEMBERED SESSION
  // Restores the persisted session (token already stored) into auth state so
  // the user skips re-entering email/password.

  void continueRemembered() {
    final session = ref.read(userSessionServiceProvider);
    if (!session.hasSession) return;

    final image = session.profileImage;
    state = state.copyWith(
      status: AuthStatus.authenticated,
      authEntity: AuthEntity(
        authId: session.userId,
        name: session.fullName ?? '',
        email: session.email ?? '',
        imageUrl: (image != null && image.isNotEmpty) ? image : null,
      ),
    );
  }

  // FORGOT PASSWORD

  Future<void> forgotPassword({required String emailOrPhone}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = ForgotPasswordParams(emailOrPhone: emailOrPhone);
    final result = await ref.read(forgotPasswordUsecaseProvider).call(params);

    result.fold(
      (failure) {
        if (kDebugMode) print('ForgotPassword failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        if (kDebugMode) print('Reset link sent');
        state = state.copyWith(status: AuthStatus.resetLinkSent);
      },
    );
  }

  // RESET PASSWORD

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = ResetPasswordParams(
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    final result = await ref.read(resetPasswordUsecaseProvider).call(params);

    result.fold(
      (failure) {
        if (kDebugMode) print('ResetPassword failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        if (kDebugMode) print('Password reset successfully');
        state = state.copyWith(status: AuthStatus.passwordResetSuccess);
      },
    );
  }

  // LOGOUT

  Future<void> logout() async {
    await ref.read(logoutUsecaseProvider).call();
    state = const AuthState();
  }

  // UPDATE PROFILE

  Future<void> updateAuthEntity({
    required String name,
    required String email,
    String? imagePath,
  }) async {
    final current = state.authEntity;
    if (current == null || current.authId == null) return;

    // Persist name (and any new avatar) to the backend, and read back the
    // stored image URL so it survives restarts and shows on every device.
    String? imageUrl = current.imageUrl;
    try {
      final stored = await ref
          .read(authRemoteDatasourceProvider)
          .updateProfile(name: name, email: email, imagePath: imagePath);
      if (stored != null && stored.isNotEmpty) {
        imageUrl = stored;
      }
    } catch (e) {
      if (kDebugMode) print('updateProfile remote failed: $e');
      // Fall through — still update the name locally below.
    }

    final updated = AuthEntity(
      authId: current.authId,
      name: name,
      email: email,
      imageUrl: imageUrl,
      role: current.role,
    );

    state = state.copyWith(authEntity: updated);

    await ref.read(hiveServiceProvider).updateUserEmail(current.authId!, email);
  }
}
