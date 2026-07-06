import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/core/services/storage/user_session.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/auth_api_model.dart';

import '../../../../../core/api/api_endpoints.dart';
import '../../../../../core/api/app_client.dart';
import '../../../../../core/services/storage/token_service.dart';

import '../auth_datasource.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  // LOGIN

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) print('Full Login Response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          if (kDebugMode) print('No data in response');
          return null;
        }

        final parsed = AuthApiModel.fromJson(data);

        // Resolve the (possibly relative) /uploads/... path to an absolute URL
        // so the profile avatar loads right after login, not only after an edit.
        final resolvedImage = _resolveImageUrl(parsed.imageUrl);
        final user = AuthApiModel(
          id: parsed.id,
          name: parsed.name,
          email: parsed.email,
          password: parsed.password,
          imageUrl: resolvedImage,
          role: parsed.role,
        );

        // Save session
        await _userSessionService.saveUserSession(
          userId: user.id ?? '',
          email: user.email,
          fullName: user.name,
          profileImage: resolvedImage ?? '',
        );

        // Extract token — handle multiple possible key names from the backend
        final token =
            response.data['token'] ??
            response.data['accessToken'] ??
            response.data['access_token'];

        if (kDebugMode)
          print('Token found: ${token != null ? 'Yes' : 'No'}');

        if (token != null && token is String) {
          await _tokenService.saveToken(token);
          final saved = _tokenService.getToken();
          if (kDebugMode) print('Token saved: ${saved != null ? 'yes' : 'no'}');
        } else {
          if (kDebugMode) print('No valid token in response');
        }

        return user;
      } else {
        if (kDebugMode) print('Login failed: ${response.data['message']}');
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return null;
    }
  }

  // REGISTER

  @override
  Future<AuthApiModel?> registerUser(
    AuthApiModel user, {
    String? confirmPassword,
  }) async {
    try {
      if (kDebugMode) {
        print('RegisterUser called with confirmPassword: $confirmPassword');
      }

      final requestData = {
        ...user.toJson(),
        'confirmPassword': confirmPassword,
      };

      // Remove null _id — let MongoDB auto-generate it
      requestData.remove('_id');

      if (kDebugMode) print('Sending request data: $requestData');

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (kDebugMode) print('Register DioException: ${e.response?.data}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Register error: $e');
      rethrow;
    }
  }

  // FORGOT PASSWORD

  @override
  Future<bool> forgotPassword(String emailOrPhone) async {
    try {
      if (kDebugMode) print('Forgot password request for: $emailOrPhone');

      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email_or_phone': emailOrPhone},
      );

      if (kDebugMode) print('Forgot password response: ${response.data}');

      if (response.data['success'] == true) {
        if (kDebugMode) print('Reset link sent');
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to send reset link.',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('ForgotPassword DioException: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) print('ForgotPassword error: $e');
      rethrow;
    }
  }

  // UPDATE PROFILE (name + optional avatar image)

  @override
  Future<String?> updateProfile({
    required String name,
    String? email,
    String? imagePath,
  }) async {
    try {
      final formMap = <String, dynamic>{'name': name};

      if (email != null && email.isNotEmpty) {
        formMap['email'] = email;
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        formMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.patch(
        ApiEndpoints.updateMe,
        data: formData,
      );

      if (response.data['success'] == true) {
        // Backend returns the updated record under `user`.
        final user = response.data['user'] as Map<String, dynamic>?;
        final rawImage = user?['imageUrl'] as String?;

        final resolved = _resolveImageUrl(rawImage);

        // Keep the local session in sync (resolved image + new email).
        await _userSessionService.saveUserSession(
          userId: _userSessionService.userId ?? (user?['_id'] as String? ?? ''),
          email: (user?['email'] as String?) ??
              email ??
              _userSessionService.email ??
              '',
          fullName: name,
          profileImage: resolved ?? _userSessionService.profileImage ?? '',
        );

        return resolved;
      }

      throw Exception(response.data['message'] ?? 'Profile update failed.');
    } on DioException catch (e) {
      if (kDebugMode) print('UpdateProfile DioException: ${e.response?.data}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('UpdateProfile error: $e');
      rethrow;
    }
  }

  /// Resolves a backend image path to an absolute URL the client can load.
  /// Relative `/uploads/...` paths are prefixed with the server origin.
  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '${ApiEndpoints.serverOrigin}$path';
  }

  // RESET PASSWORD

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (kDebugMode) print('Reset password request with token: $token');

      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (kDebugMode) print('Reset password response: ${response.data}');

      if (response.data['success'] == true) {
        if (kDebugMode) print('Password reset successful');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Password reset failed.');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('ResetPassword DioException: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) print('ResetPassword error: $e');
      rethrow;
    }
  }
}
