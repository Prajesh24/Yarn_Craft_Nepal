import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/app_client.dart';
import '../../catalog/domain/entity/product_entity.dart';

final adminProductDatasourceProvider = Provider<AdminProductDatasource>(
  (ref) => AdminProductDatasource(ref.read(apiClientProvider)),
);

class AdminProductDatasource {
  final ApiClient _api;
  AdminProductDatasource(this._api);

  String? _resolveImage(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) return null;
    return s.startsWith('http') ? s : '${ApiEndpoints.serverOrigin}$s';
  }

  ProductEntity _map(Map<String, dynamic> json) {
    final imageUrl = _resolveImage(json['imageUrl'] as String?);
    final rawImages = (json['images'] as List?) ?? const [];
    final images = rawImages
        .map((e) => _resolveImage(e?.toString()))
        .whereType<String>()
        .toList();
    final price = json['price'];
    return ProductEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: (json['location'] as String?)?.trim().isNotEmpty == true
          ? (json['location'] as String).trim()
          : 'Nepal',
      priceNPR: price is num ? price.toDouble() : double.tryParse('$price') ?? 0,
      imageUrl: imageUrl,
      category: (json['category'] as String?)?.trim().isEmpty ?? true
          ? 'Other'
          : (json['category'] as String).trim(),
      images: images,
      colors: ((json['colors'] as List?) ?? const [])
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  Future<ProductEntity> createProduct({
    required String name,
    required String description,
    required String location,
    required String category,
    required double price,
    required int quantity,
    List<String> colors = const [],
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'price': price.toString(),
      'quantity': quantity.toString(),
      'colors': colors.join(','),
      if (imagePath != null)
        'imageUrl': await MultipartFile.fromFile(imagePath),
    });
    final res = await _api.post(ApiEndpoints.products, data: formData);
    return _map(res.data['data'] as Map<String, dynamic>);
  }

  Future<ProductEntity> updateProduct({
    required String id,
    required String name,
    required String description,
    required String location,
    required String category,
    required double price,
    required int quantity,
    List<String> colors = const [],
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'price': price.toString(),
      'quantity': quantity.toString(),
      'colors': colors.join(','),
      if (imagePath != null)
        'imageUrl': await MultipartFile.fromFile(imagePath),
    });
    final res = await _api.put(ApiEndpoints.productById(id), data: formData);
    return _map(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete(ApiEndpoints.productById(id));
  }
}
