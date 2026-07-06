import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/order_remote_datasource.dart';
import '../../domain/order_entity.dart';

/// Fetches the signed-in user's orders, newest first.
/// Refreshed with `ref.invalidate(myOrdersProvider)` after placing/cancelling.
final myOrdersProvider = FutureProvider<List<OrderEntity>>((ref) async {
  return ref.read(orderRemoteDatasourceProvider).getMyOrders();
});

/// Imperative actions for placing and cancelling orders.
final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref);
});

class OrderActions {
  final Ref _ref;
  OrderActions(this._ref);

  Future<OrderEntity> placeOrder({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
  }) async {
    final order = await _ref
        .read(orderRemoteDatasourceProvider)
        .createOrder(
          items: items,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          total: total,
          paymentMethod: paymentMethod,
        );
    // Make the order history reflect the new order on next view.
    _ref.invalidate(myOrdersProvider);
    if (kDebugMode) print('Order placed: ${order.orderNumber}');
    return order;
  }

  Future<void> cancelOrder(String orderId) async {
    await _ref.read(orderRemoteDatasourceProvider).cancelOrder(orderId);
    _ref.invalidate(myOrdersProvider);
  }

  Future<void> markReceived(String orderId) async {
    await _ref.read(orderRemoteDatasourceProvider).markReceived(orderId);
    _ref.invalidate(myOrdersProvider);
  }
}
