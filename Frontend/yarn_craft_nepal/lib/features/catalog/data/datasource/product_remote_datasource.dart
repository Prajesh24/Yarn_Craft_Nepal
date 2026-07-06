import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/app_client.dart';
import '../../domain/entity/product_entity.dart';

final productRemoteDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

/// Fetches products from the YarnCraft backend (`GET /api/v1/products`).
class ProductRemoteDatasource {
  final ApiClient _apiClient;

  ProductRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<List<ProductEntity>> getProducts() async {
    final response = await _apiClient.get(ApiEndpoints.products);

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to load products.');
    }

    final list = (response.data['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_mapToEntity)
        .toList(growable: false);
  }

  /// Turns a backend image path (absolute URL or relative `/uploads/...`)
  /// into an absolute URL the client can load.
  String? _resolveImage(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) return null;
    return s.startsWith('http') ? s : '${ApiEndpoints.serverOrigin}$s';
  }

  ProductEntity _mapToEntity(Map<String, dynamic> json) {
    final imageUrl = _resolveImage(json['imageUrl'] as String?);

    final rawImages = (json['images'] as List?) ?? const [];
    final images = rawImages
        .map((e) => _resolveImage(e?.toString()))
        .whereType<String>()
        .toList(growable: false);

    final price = json['price'];
    final priceNPR = price is num
        ? price.toDouble()
        : double.tryParse('$price') ?? 0.0;

    if (kDebugMode && imageUrl != null) {
      // Helps confirm image resolution while wiring things up.
      // ignore: avoid_print
      print('Product image: $imageUrl');
    }

    final category = (json['category'] as String?)?.trim();

    final id = (json['_id'] ?? json['id'] ?? '').toString();

    final qty = json['quantity'];
    final stock = qty is num ? qty.toInt() : int.tryParse('$qty') ?? 0;

    return ProductEntity(
      id: id,
      name: (json['name'] ?? 'Unnamed product').toString(),
      location: (json['location'] as String?)?.trim().isNotEmpty == true
          ? (json['location'] as String).trim()
          : (json['description'] as String?)?.trim().isNotEmpty == true
              ? (json['description'] as String).trim()
              : 'Nepal',
      priceNPR: priceNPR,
      imageUrl: imageUrl,
      category: (category == null || category.isEmpty) ? 'Other' : category,
      stock: stock,
      batchNo: _batchNoFrom(id, json['createdAt']?.toString()),
      images: images,
      colors: ((json['colors'] as List?) ?? const [])
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// Derives a stable, human-readable batch/lot number from the product id and
  /// creation date, e.g. `YCN-2026-1A2B3C`. Deterministic (same product always
  /// shows the same batch number) and needs no extra backend field.
  String _batchNoFrom(String id, String? createdAt) {
    final year = DateTime.tryParse(createdAt ?? '')?.year ?? DateTime.now().year;
    final hex = id.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final suffix = (hex.length >= 6 ? hex.substring(hex.length - 6) : hex)
        .toUpperCase()
        .padLeft(6, '0');
    return 'YCN-$year-$suffix';
  }
}
