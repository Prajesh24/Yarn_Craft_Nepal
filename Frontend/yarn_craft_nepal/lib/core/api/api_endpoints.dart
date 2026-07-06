import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Port the backend (YarnCraft Backend) listens on — see backend `.env` PORT.
  static const String _port = '5051';

  /// Host that points at the developer machine running the backend.
  ///
  /// - Android emulator reaches the host machine via the special IP 10.0.2.2.
  /// - iOS simulator, macOS/Windows/Linux desktop and web all use localhost.
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {
      // Platform isn't available (e.g. web) — fall through to localhost.
    }
    return 'localhost';
  }

  /// Root URL of the API, e.g. http://localhost:5051/api/v1
  static String get baseUrl => 'http://$_host:$_port/api/v1';

  /// Server origin without the /api/v1 suffix — used to resolve image URLs
  /// that the backend returns as relative paths (e.g. /uploads/abc.png).
  static String get serverOrigin => 'http://$_host:$_port';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String getMe = '/auth/me';
  static const String updateMe = '/auth/me/update';
  static const String changePassword = '/auth/change-password';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Cart
  static const String cart = '/cart';

  // Favourites
  static const String favourites = '/favourites';

  // Orders
  static const String orders = '/orders';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String markOrderReceived(String id) => '/orders/$id/received';
}
