import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/viewmodel/product_viewmodel.dart';
import '../../data/admin_product_datasource.dart';

enum AdminProductStatus { idle, loading, success, error }

class AdminProductState {
  final AdminProductStatus status;
  final String? errorMessage;

  const AdminProductState({
    this.status = AdminProductStatus.idle,
    this.errorMessage,
  });

  AdminProductState copyWith({
    AdminProductStatus? status,
    String? errorMessage,
  }) => AdminProductState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

final adminProductProvider =
    NotifierProvider<AdminProductNotifier, AdminProductState>(
      AdminProductNotifier.new,
    );

class AdminProductNotifier extends Notifier<AdminProductState> {
  @override
  AdminProductState build() => const AdminProductState();

  AdminProductDatasource get _ds => ref.read(adminProductDatasourceProvider);

  Future<bool> createProduct({
    required String name,
    required String description,
    required String location,
    required String category,
    required double price,
    required int quantity,
    List<String> colors = const [],
    String? imagePath,
  }) async {
    state = state.copyWith(status: AdminProductStatus.loading, errorMessage: null);
    try {
      await _ds.createProduct(
        name: name,
        description: description,
        location: location,
        category: category,
        price: price,
        quantity: quantity,
        colors: colors,
        imagePath: imagePath,
      );
      state = state.copyWith(status: AdminProductStatus.success);
      ref.invalidate(productsProvider);
      return true;
    } catch (e) {
      if (kDebugMode) print('createProduct failed: $e');
      state = state.copyWith(
        status: AdminProductStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProduct({
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
    state = state.copyWith(status: AdminProductStatus.loading, errorMessage: null);
    try {
      await _ds.updateProduct(
        id: id,
        name: name,
        description: description,
        location: location,
        category: category,
        price: price,
        quantity: quantity,
        colors: colors,
        imagePath: imagePath,
      );
      state = state.copyWith(status: AdminProductStatus.success);
      ref.invalidate(productsProvider);
      return true;
    } catch (e) {
      if (kDebugMode) print('updateProduct failed: $e');
      state = state.copyWith(
        status: AdminProductStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(status: AdminProductStatus.loading, errorMessage: null);
    try {
      await _ds.deleteProduct(id);
      state = state.copyWith(status: AdminProductStatus.success);
      ref.invalidate(productsProvider);
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteProduct failed: $e');
      state = state.copyWith(
        status: AdminProductStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const AdminProductState();
}
