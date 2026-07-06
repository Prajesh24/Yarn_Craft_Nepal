import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/core/services/storage/user_session.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/hive_model.dart';

import '../../../../../core/services/hive/hive_service.dart';
import '../../../../../core/services/storage/token_service.dart';

import '../auth_datasource.dart';

final authLocalDataSourceProvider = Provider<IAuthLocalDatasource>((ref) {
  return AuthLocalDatasource(
    hiveService: ref.read(hiveServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final TokenService _tokenService;
  final UserSessionService _userSessionService;

  const AuthLocalDatasource({
    required HiveService hiveService,
    required TokenService tokenService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _tokenService = tokenService,
       _userSessionService = userSessionService;

  // REGISTER

  @override
  Future<bool> registerUser(AuthHiveModel user) async {
    try {
      // Prevent duplicate emails
      if (_hiveService.emailExists(user.email)) {
        throw Exception('An account with this email already exists.');
      }
      await _hiveService.saveUser(user);
      if (kDebugMode) print('Local register: ${user.email}');
      return true;
    } catch (e) {
      if (kDebugMode) print('Local register error: $e');
      rethrow;
    }
  }

  // LOGIN

  @override
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = _hiveService.getUserByEmail(email);

      if (user == null) {
        if (kDebugMode) print('Local login: user not found ($email)');
        return null;
      }

      // Simple password comparison — in production, use bcrypt
      if (user.password != password) {
        if (kDebugMode) print('Local login: wrong password');
        return null;
      }

      // Save session
      await _userSessionService.saveUserSession(
        userId: user.authId ?? '',
        email: user.email,
        fullName: user.name,
        profileImage: user.imageUrl ?? '',
      );

      if (user.authId != null) {
        await _hiveService.saveCurrentUserId(user.authId!);
      }

      if (kDebugMode) print('Local login: ${user.email}');
      return user;
    } catch (e) {
      if (kDebugMode) print('Local login error: $e');
      rethrow;
    }
  }

  // GET CURRENT USER

  @override
  Future<AuthHiveModel?> getCurrentUser(String authId) async {
    try {
      // First try by ID; fall back to session email
      final id = _hiveService.getCurrentUserId();
      if (id != null) {
        final user = _hiveService.getUserById(id);
        if (user != null) return user;
      }

      // Fall back to session email
      final email = _userSessionService.email;
      if (email != null) return _hiveService.getUserByEmail(email);

      return null;
    } catch (e) {
      if (kDebugMode) print('getCurrentUser error: $e');
      return null;
    }
  }

  // LOGOUT

  @override
  Future<bool> logoutUser() async {
    try {
      await _tokenService.deleteToken();
      await _userSessionService.clearSession();
      await _hiveService.clearSession();
      if (kDebugMode) print('Logout complete');
      return true;
    } catch (e) {
      if (kDebugMode) print('Logout error: $e');
      return false;
    }
  }

  // EMAIL EXISTS

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.emailExists(email);
  }
}
