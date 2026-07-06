import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

/// Stores the JWT access token in a Hive box.
class TokenService {
  static const String _boxName = 'token_box';
  static const String _tokenKey = 'access_token';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  /// Call once in [HiveService.init].
  static Future<void> init() async {
    await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  String? getToken() {
    return _box.get(_tokenKey) as String?;
  }

  Future<void> deleteToken() async {
    await _box.delete(_tokenKey);
  }

  bool get hasToken {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
