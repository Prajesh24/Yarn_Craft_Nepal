import 'package:yarn_craft_nepal/features/auth/data/model/auth_api_model.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/hive_model.dart';

/// Remote datasource contract
abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel?> loginUser(String email, String password);

  Future<AuthApiModel?> registerUser(
    AuthApiModel user, {
    String? confirmPassword,
  });

  /// Sends a password-reset link to [emailOrPhone].
  /// Returns true if the server accepted the request.
  Future<bool> forgotPassword(String emailOrPhone);

  /// Resets the password using the [token] from the email/SMS link.
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  /// Updates the signed-in user's profile. Optionally uploads a new avatar
  /// from [imagePath]. Returns the stored (absolute) image URL, or null.
  Future<String?> updateProfile({
    required String name,
    String? email,
    String? imagePath,
  });
}

/// Local (Hive) datasource contract
abstract interface class IAuthLocalDatasource {
  Future<bool> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String authId);
  Future<bool> logoutUser();
  Future<bool> isEmailExists(String email);
}
