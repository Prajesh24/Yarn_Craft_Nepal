import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/app_client.dart';

final favouriteRemoteDatasourceProvider = Provider<FavouriteRemoteDatasource>((
  ref,
) {
  return FavouriteRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

/// Talks to the favourites API (`/api/v1/favourites`). The auth Bearer token is
/// attached automatically by [ApiClient]'s interceptor.
class FavouriteRemoteDatasource {
  final ApiClient _apiClient;

  FavouriteRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Returns the saved product ids for the current user.
  Future<List<String>> getFavouriteIds() async {
    final response = await _apiClient.get(ApiEndpoints.favourites);
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to load favourites.');
    }
    final data = response.data['data'] as Map<String, dynamic>?;
    final ids = (data?['productIds'] as List?) ?? const [];
    return ids.map((e) => e.toString()).toList(growable: false);
  }

  /// Persists the full set of saved product ids for the current user.
  Future<void> setFavouriteIds(List<String> productIds) async {
    await _apiClient.put(
      ApiEndpoints.favourites,
      data: {'productIds': productIds},
    );
  }
}
