import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/app_client.dart';
import '../../../../core/services/storage/token_service.dart';
import '../../domain/entity/product_entity.dart';
import '../state/cart_state.dart';
import 'product_viewmodel.dart';

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(() => CartNotifier());

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Loads the signed-in user's saved cart from the backend (`GET /api/v1/cart`)
  /// and rebuilds the local cart, resolving each stored productId against the
  /// product catalogue (so names, prices and images are restored). Call this
  /// after login / on app start so the cart survives restarts.
  Future<void> loadFromBackend() async {
    final tokenService = ref.read(tokenServiceProvider);
    if (!tokenService.hasToken) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.get(ApiEndpoints.cart);
      final rawItems = (res.data['data']?['items'] as List?) ?? const [];
      if (rawItems.isEmpty) {
        state = const CartState();
        return;
      }

      // Resolve productIds against the live catalogue.
      final products = await ref.read(productsProvider.future);

      final items = <CartItem>[];
      for (final raw in rawItems) {
        final pid = (raw['productId'] is Map)
            ? raw['productId']['_id'] as String?
            : raw['productId'] as String?;
        final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
        if (pid == null) continue;

        final matches = products.where((p) => p.id == pid);
        if (matches.isEmpty) continue;
        final ProductEntity product = matches.first;

        items.add(
          CartItem(
            id: product.id,
            name: product.name,
            priceNPR: product.priceNPR,
            quantity: qty,
            imageUrl: product.imageUrl,
            location: product.location,
          ),
        );
      }

      state = state.copyWith(items: items);
      if (kDebugMode) print('Cart loaded (${items.length} items)');
    } catch (e) {
      if (kDebugMode) print('Cart load failed: $e');
    }
  }

  void addItem(CartItem item) {
    final idx = state.items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      final updated = List<CartItem>.from(state.items);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
    _syncToBackend();
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    _syncToBackend();
  }

  void increaseQty(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) return item.copyWith(quantity: item.quantity + 1);
        return item;
      }).toList(),
    );
    _syncToBackend();
  }

  void decreaseQty(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id && item.quantity > 1) {
          return item.copyWith(quantity: item.quantity - 1);
        }
        return item;
      }).toList(),
    );
    _syncToBackend();
  }

  void clearCart() {
    state = const CartState();
    _syncToBackend();
  }

  /// Best-effort sync of the local cart to the backend (`PUT /api/v1/cart`).
  ///
  /// Local state stays the source of truth for the UI; this just persists the
  /// cart server-side for the signed-in user. It silently no-ops when the user
  /// isn't logged in (no token) or the backend is unreachable, so the cart
  /// keeps working offline.
  Future<void> _syncToBackend() async {
    final tokenService = ref.read(tokenServiceProvider);
    if (!tokenService.hasToken) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        ApiEndpoints.cart,
        data: {
          'items': state.items
              .map((i) => {'productId': i.id, 'quantity': i.quantity})
              .toList(),
        },
      );
      if (kDebugMode) print('Cart synced (${state.items.length} items)');
    } catch (e) {
      if (kDebugMode) print('Cart sync failed (kept locally): $e');
    }
  }
}
