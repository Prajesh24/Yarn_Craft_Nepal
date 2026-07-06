import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/hive_model.dart';
import 'package:yarn_craft_nepal/features/auth/data/model/hive_model.g.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

/// Box names — centralised so a typo never causes a mismatch.
class HiveBoxNames {
  static const String auth = 'auth_box';
  static const String session = 'session_box';
}

/// Manages Hive box initialisation and common operations.
class HiveService {
  // Initialisation (call once in main())

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters — only if not already registered
    if (!Hive.isAdapterRegistered(AuthHiveModelAdapter().typeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    // Open boxes
    await Hive.openBox<AuthHiveModel>(HiveBoxNames.auth);
    await Hive.openBox<dynamic>(HiveBoxNames.session);
  }

  // Auth box helpers

  Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(HiveBoxNames.auth);
  Box<dynamic> get _sessionBox => Hive.box<dynamic>(HiveBoxNames.session);

  Future<void> saveUser(AuthHiveModel user) async {
    await _authBox.put(user.authId ?? user.email, user);
  }

  AuthHiveModel? getUserByEmail(String email) {
    return _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email,
      orElse: () => null,
    );
  }

  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  bool emailExists(String email) {
    return _authBox.values.any((u) => u.email == email);
  }

  /// Updates just the email of an existing user — called from AuthViewModel.
  Future<void> updateUserEmail(String authId, String newEmail) async {
    final user = _authBox.get(authId);
    if (user == null) return;
    final updated = AuthHiveModel(
      authId: user.authId,
      name: user.name,
      email: newEmail,
      password: user.password,
      imageUrl: user.imageUrl,
      role: user.role,
    );
    await _authBox.put(authId, updated);
  }

  // Session box helpers

  Future<void> saveCurrentUserId(String authId) async {
    await _sessionBox.put('current_user_id', authId);
  }

  String? getCurrentUserId() {
    return _sessionBox.get('current_user_id') as String?;
  }

  Future<void> clearSession() async {
    await _sessionBox.delete('current_user_id');
  }
}
