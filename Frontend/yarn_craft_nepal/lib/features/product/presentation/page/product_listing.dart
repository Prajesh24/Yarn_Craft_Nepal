import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entity/product_entity.dart';
import '../../../catalog/presentation/page/saved_item.dart';
import '../../../catalog/presentation/viewmodel/product_filter_viewmodel.dart';
import '../../../catalog/presentation/viewmodel/product_viewmodel.dart';
import '../../../catalog/presentation/viewmodel/saved_viewmodel.dart';
import 'filter.dart';
import 'product_description_page.dart';

class ProductListingPage extends ConsumerStatefulWidget {
  const ProductListingPage({super.key});

  @override
  ConsumerState<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends ConsumerState<ProductListingPage> {
  final _searchCtrl = TextEditingController();

  // Local sample data — used only as a fallback when the backend is
  // unreachable so the screen never renders empty during development.
  final List<ProductEntity> _fallbackProducts = const [
    ProductEntity(
      id: 'pl1',
      name: 'Hand-loomed Organic Hemp',
      location: 'Pokhara Valley',
      priceNPR: 1200,
      category: 'Hemp',
      badge: 'VERIFIED',
      badgeColor: Color(0xFF1B6B61),
    ),
    ProductEntity(
      id: 'pl2',
      name: 'Indigo Dyed Hemp Canvas',
      location: 'Kathmandu',
      priceNPR: 2500,
      category: 'Hemp',
    ),
    ProductEntity(
      id: 'pl3',
      name: 'Raw Hemp Fiber Blend',
      location: 'Lalitpur',
      priceNPR: 950,
      category: 'Hemp',
      badge: 'HANDMADE',
      badgeColor: Color(0xFFF59E0B),
    ),
    ProductEntity(
      id: 'pl4',
      name: 'Fine Weave Apparel Hemp',
      location: 'Bhaktapur',
      priceNPR: 1800,
      category: 'Hemp',
      badge: 'VERIFIED',
      badgeColor: Color(0xFF1B6B61),
    ),
  ];

  final List<Map<String, String>> _ratings = const [
    {'rating': '4.8', 'reviews': '42'},
    {'rating': '4.6', 'reviews': '18'},
    {'rating': '4.2', 'reviews': '9'},
    {'rating': '4.9', 'reviews': '112'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openProduct(ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }

  String _priceLabel(ProductFilter f) {
    final min = f.minPrice.round();
    final max = f.maxPrice.round();
    if (min <= 0) return 'Under Rs. $max';
    return 'Rs. $min – $max';
  }

  @override
  Widget build(BuildContext context) {
    // Live products from the backend; fall back to local samples on error.
    final productsAsync = ref.watch(productsProvider);
    final liveProducts = productsAsync.asData?.value ?? const <ProductEntity>[];
    final base = liveProducts.isNotEmpty ? liveProducts : _fallbackProducts;

    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);

    final products = applyProductFilter(base, filter);
    final categories = categoriesFrom(base); // ['All', ...]
    final selectedCategory = filter.categories.isEmpty
        ? 'All'
        : (filter.categories.length == 1 ? filter.categories.first : null);

    final priceActive =
        filter.minPrice > ProductFilter.priceFloor ||
        filter.maxPrice < ProductFilter.priceCeil;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: notifier.setQuery,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search yarns, fabrics, places…',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          suffixIcon: filter.query.isEmpty
                              ? null
                              : GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    notifier.setQuery('');
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF9CA3AF),
                                    size: 18,
                                  ),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedItemsPage(),
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color(0xFF6B7280),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Results + count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      filter.query.trim().isEmpty
                          ? 'All products'
                          : 'Results for "${filter.query.trim()}"',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${products.length} items',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Category selector
            SizedBox(
              height: 32,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = categories[i];
                  return _CategoryChip(
                    label: c,
                    selected: c == selectedCategory,
                    onTap: () => notifier.selectCategory(c),
                  );
                },
              ),
            ),

            // Active filter chips (price + multi-category)
            if (priceActive ||
                (selectedCategory == null && filter.categories.isNotEmpty)) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (selectedCategory == null)
                      ...filter.categories.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _RemovableChip(
                            label: c,
                            onRemove: () => notifier.removeCategory(c),
                          ),
                        ),
                      ),
                    if (priceActive)
                      _RemovableChip(
                        label: _priceLabel(filter),
                        onRemove: notifier.clearPrice,
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Sort + Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  PopupMenuButton<ProductSort>(
                    onSelected: notifier.setSort,
                    itemBuilder: (_) => ProductSort.values
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(s.label),
                          ),
                        )
                        .toList(),
                    child: Row(
                      children: [
                        Text(
                          'Sort by: ${filter.sort.label}',
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF374151),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showFilterSheet(
                      context,
                      categories.where((c) => c != 'All').toList(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF1B6B61), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          filter.hasActiveFilters ? 'Filters •' : 'Filters',
                          style: const TextStyle(
                            color: Color(0xFF1B6B61),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Product grid
            Expanded(
              child: products.isEmpty
                  ? const _NoResults()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      // Responsive: column count adapts to screen width so the
                      // grid looks right on phones, tablets and wide screens.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final product = products[i];
                        final rating = _ratings[i % _ratings.length];
                        return _ListingCard(
                          product: product,
                          rating: rating['rating']!,
                          reviews: rating['reviews']!,
                          onTap: () => _openProduct(product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// No results state

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.search_off, color: Color(0xFFD1D5DB), size: 64),
        SizedBox(height: 14),
        Text(
          'No products match',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Try a different search or adjust your filters.',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ],
    ),
  );
}

// Category chip

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1B6B61);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// Removable active-filter chip

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 10, right: 6, top: 5, bottom: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF1B6B61),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, color: Colors.white, size: 13),
        ),
      ],
    ),
  );
}

// Listing card

class _ListingCard extends ConsumerWidget {
  final ProductEntity product;
  final String rating, reviews;
  final VoidCallback onTap;

  const _ListingCard({
    required this.product,
    required this.rating,
    required this.reviews,
    required this.onTap,
  });

  Color get _badgeColor {
    if (product.badge == 'VERIFIED') return const Color(0xFF1B6B61);
    if (product.badge == 'HANDMADE') return const Color(0xFFF59E0B);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedProvider).contains(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFFD6CEC7),
                    child:
                        (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.texture,
                              color: Color(0xFF9CA3AF),
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.texture,
                            color: Color(0xFF9CA3AF),
                            size: 36,
                          ),
                  ),
                ),
                if (product.badge != null && product.badge!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(savedProvider.notifier).toggle(product.id),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved
                            ? const Color(0xFF1B6B61)
                            : const Color(0xFF9CA3AF),
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF9CA3AF),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product.location,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$rating ($reviews)',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFF1B6B61),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
