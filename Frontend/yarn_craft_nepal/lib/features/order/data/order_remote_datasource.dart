import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/app_client.dart';
import '../domain/order_entity.dart';

final orderRemoteDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

/// Talks to the orders API (`/api/v1/orders`). The auth Bearer token is
/// attached automatically by [ApiClient]'s interceptor.
class OrderRemoteDatasource {
  final ApiClient _apiClient;

  OrderRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Places a new order and returns it.
  Future<OrderEntity> createOrder({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: {
        'items': items,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'paymentMethod': paymentMethod,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to place order.');
    }
    return OrderEntity.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Returns the current user's orders, newest first.
  Future<List<OrderEntity>> getMyOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orders);
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to load orders.');
    }
    final list = (response.data['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(OrderEntity.fromJson)
        .toList(growable: false);
  }

  /// Cancels an order and returns the updated record.
  Future<OrderEntity> cancelOrder(String orderId) async {
    final response = await _apiClient.patch(ApiEndpoints.cancelOrder(orderId));
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to cancel order.');
    }
    return OrderEntity.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Marks an order as delivered (user confirms receipt).
  Future<OrderEntity> markReceived(String orderId) async {
    final response =
        await _apiClient.patch(ApiEndpoints.markOrderReceived(orderId));
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to mark order as received.');
    }
    return OrderEntity.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
