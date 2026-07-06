import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/product_entity.dart';

/// How the product list is ordered.
enum ProductSort { popularity, priceLowToHigh, priceHighToLow, nameAZ }

extension ProductSortLabel on ProductSort {
  String get label {
    switch (this) {
      case ProductSort.popularity:
        return 'Popularity';
      case ProductSort.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSort.priceHighToLow:
        return 'Price: High to Low';
      case ProductSort.nameAZ:
        return 'Name: A to Z';
    }
  }
}

/// The active search / filter / sort criteria for the product catalogue.
class ProductFilter {
  static const double priceFloor = 0;
  static const double priceCeil = 20000;

  final String query;
  final Set<String> categories; // empty = all categories
  final double minPrice;
  final double maxPrice;
  final ProductSort sort;

  const ProductFilter({
    this.query = '',
    this.categories = const {},
    this.minPrice = priceFloor,
    this.maxPrice = priceCeil,
    this.sort = ProductSort.popularity,
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      minPrice > priceFloor ||
      maxPrice < priceCeil ||
      sort != ProductSort.popularity;

  ProductFilter copyWith({
    String? query,
    Set<String>? categories,
    double? minPrice,
    double? maxPrice,
    ProductSort? sort,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      () => ProductFilterNotifier(),
    );

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setSort(ProductSort value) => state = state.copyWith(sort: value);

  /// Single-select category (from the chips row). Pass 'All' to clear.
  void selectCategory(String category) {
    state = state.copyWith(
      categories: category == 'All' ? <String>{} : {category},
    );
  }

  void removeCategory(String category) {
    state = state.copyWith(categories: {...state.categories}..remove(category));
  }

  void clearPrice() => state = state.copyWith(
    minPrice: ProductFilter.priceFloor,
    maxPrice: ProductFilter.priceCeil,
  );

  /// Apply the multi-select filter sheet result in one shot.
  void apply({
    required Set<String> categories,
    required double minPrice,
    required double maxPrice,
  }) {
    state = state.copyWith(
      categories: categories,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  /// Clear all filters but keep the current search query.
  void reset() => state = ProductFilter(query: state.query);
}

/// Applies the [filter] to [products]: search text, categories, price range,
/// then sorting. Returns a new list (does not mutate the input).
List<ProductEntity> applyProductFilter(
  List<ProductEntity> products,
  ProductFilter filter,
) {
  final q = filter.query.trim().toLowerCase();

  final filtered = products.where((p) {
    final matchesQuery =
        q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        p.location.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q);

    final matchesCategory =
        filter.categories.isEmpty || filter.categories.contains(p.category);

    final matchesPrice =
        p.priceNPR >= filter.minPrice && p.priceNPR <= filter.maxPrice;

    return matchesQuery && matchesCategory && matchesPrice;
  }).toList();

  switch (filter.sort) {
    case ProductSort.priceLowToHigh:
      filtered.sort((a, b) => a.priceNPR.compareTo(b.priceNPR));
      break;
    case ProductSort.priceHighToLow:
      filtered.sort((a, b) => b.priceNPR.compareTo(a.priceNPR));
      break;
    case ProductSort.nameAZ:
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      break;
    case ProductSort.popularity:
      break; // keep backend order
  }

  return filtered;
}

/// Distinct categories present in [products], prefixed with 'All'.
List<String> categoriesFrom(List<ProductEntity> products) {
  final set = <String>{};
  for (final p in products) {
    if (p.category.trim().isNotEmpty) set.add(p.category);
  }
  final list = set.toList()..sort();
  return ['All', ...list];
}
