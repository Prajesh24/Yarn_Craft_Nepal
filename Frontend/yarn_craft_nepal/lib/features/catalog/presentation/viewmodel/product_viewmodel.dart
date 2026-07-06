import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/product_remote_datasource.dart';
import '../../domain/entity/product_entity.dart';

/// Fetches the live product catalog from the backend.
///
/// UI screens watch this and fall back to their local sample data if the
/// request fails (e.g. backend not running), so the app never shows a blank
/// screen during development.
final productsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final datasource = ref.read(productRemoteDatasourceProvider);
  try {
    return await datasource.getProducts();
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Failed to load products from API: $e');
    }
    rethrow;
  }
});
