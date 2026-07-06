import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});

/// Stores lightweight session data (userId, email, name, profileImage)
/// separately from the full Hive user record.
class UserSessionService {
  static const String _boxName = 'user_session_box';

  static const String _kUserId = 'session_user_id';
  static const String _kEmail = 'session_email';
  static const String _kFullName = 'session_full_name';
  static const String _kProfileImage = 'session_profile_image';
  static const String _kRememberMe = 'session_remember_me';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String profileImage = '',
  }) async {
    await _box.put(_kUserId, userId);
    await _box.put(_kEmail, email);
    await _box.put(_kFullName, fullName);
    await _box.put(_kProfileImage, profileImage);
  }

  String? get userId => _box.get(_kUserId) as String?;
  String? get email => _box.get(_kEmail) as String?;
  String? get fullName => _box.get(_kFullName) as String?;
  String? get profileImage => _box.get(_kProfileImage) as String?;

  bool get hasSession => userId != null && userId!.isNotEmpty;

  /// Whether the user opted into "Remember Me" at login. When true and a
  /// session exists, the login screen can offer a one-tap "Continue as …".
  bool get rememberMe => (_box.get(_kRememberMe) as bool?) ?? false;

  Future<void> setRememberMe(bool value) async {
    await _box.put(_kRememberMe, value);
  }

  Future<void> clearSession() async {
    await _box.delete(_kUserId);
    await _box.delete(_kEmail);
    await _box.delete(_kFullName);
    await _box.delete(_kProfileImage);
    await _box.delete(_kRememberMe);
  }
}
