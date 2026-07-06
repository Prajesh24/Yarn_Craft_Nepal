import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/storage/token_service.dart';
import '../../data/datasource/favourite_remote_datasource.dart';

/// Holds the set of saved (favourited) product ids.
///
/// On creation it loads the user's favourites from the backend (when logged
/// in), and every toggle is persisted back via `PUT /api/v1/favourites`. The
/// local set stays the source of truth for the UI so hearts respond instantly
/// even when offline.
final savedProvider = NotifierProvider<SavedNotifier, Set<String>>(
  () => SavedNotifier(),
);

class SavedNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Kick off a background load; UI starts empty and fills in when it returns.
    _loadFromBackend();
    return {};
  }

  Future<void> _loadFromBackend() async {
    final tokenService = ref.read(tokenServiceProvider);
    if (!tokenService.hasToken) return;

    try {
      final ids = await ref
          .read(favouriteRemoteDatasourceProvider)
          .getFavouriteIds();
      state = ids.toSet();
      if (kDebugMode) print('Loaded ${ids.length} favourites');
    } catch (e) {
      if (kDebugMode) print('Failed to load favourites: $e');
    }
  }

  /// Re-fetch favourites from the backend (e.g. right after a fresh login).
  Future<void> refresh() => _loadFromBackend();

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = Set.from(state)..remove(productId);
    } else {
      state = Set.from(state)..add(productId);
    }
    _syncToBackend();
  }

  bool isSaved(String productId) => state.contains(productId);

  /// Best-effort persistence of the full favourites set. No-ops when the user
  /// isn't logged in or the backend is unreachable.
  Future<void> _syncToBackend() async {
    final tokenService = ref.read(tokenServiceProvider);
    if (!tokenService.hasToken) return;

    try {
      await ref
          .read(favouriteRemoteDatasourceProvider)
          .setFavouriteIds(state.toList());
      if (kDebugMode) print('Favourites synced (${state.length})');
    } catch (e) {
      if (kDebugMode) print('Favourites sync failed (kept locally): $e');
    }
  }
}
