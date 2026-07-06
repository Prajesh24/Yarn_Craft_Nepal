import 'package:equatable/equatable.dart';
import 'package:yarn_craft_nepal/features/auth/domain/entity/auth_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  resetLinkSent, // forgotPassword succeeded
  passwordResetSuccess, // resetPassword succeeded
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRegistered => status == AuthStatus.registered;
  bool get isResetLinkSent => status == AuthStatus.resetLinkSent;
  bool get isPasswordResetDone => status == AuthStatus.passwordResetSuccess;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
