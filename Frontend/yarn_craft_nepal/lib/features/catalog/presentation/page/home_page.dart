import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/catalog/domain/entity/product_entity.dart';
import '../../../../features/product/presentation/page/product_description_page.dart';
import '../viewmodel/product_filter_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../viewmodel/saved_viewmodel.dart';
import '../viewmodel/tab_viewmodel.dart';
import 'saved_item.dart';
import 'yarn_bottom_nav.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Hand-spun Yarn',
    'Pashmina',
    'Hemp',
    'Silk',
    'Wool',
  ];

  // Local sample data — used only as a fallback when the backend is
  // unreachable so the home screen never renders empty during development.
  final List<ProductEntity> _fallbackTrending = [
    const ProductEntity(
      id: 'p1',
      name: 'Organic Cotton Skein',
      location: 'Bhaktapur Weavers',
      priceNPR: 1200,
      badge: 'Handmade',
      badgeColor: Color(0xFFF59E0B),
    ),
    const ProductEntity(
      id: 'p2',
      name: 'Pure Pashmina',
      location: 'Himalayan',
      priceNPR: 8500,
      badge: 'Verified',
      badgeColor: Color(0xFF1B6B61),
    ),
    const ProductEntity(
      id: 'p3',
      name: 'Natural Hemp Roll',
      location: 'Pokhara Looms',
      priceNPR: 2100,
      badge: 'Handmade',
      badgeColor: Color(0xFFF59E0B),
    ),
  ];

  void _openProduct(ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Live products from the backend; fall back to local samples on error.
    final productsAsync = ref.watch(productsProvider);
    final liveProducts = productsAsync.asData?.value ?? const <ProductEntity>[];
    final trending =
        liveProducts.isNotEmpty ? liveProducts : _fallbackTrending;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'YarnCraft Nepal',
                    style: TextStyle(
                      color: Color(0xFF1B6B61),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
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

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Featured banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Background image — Featured Artisan Collection
                            Image.asset(
                              'assets/images/featured_artisan_bg.png',
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 220,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3D2B1F),
                                      Color(0xFF1A0A05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Dark overlay so the text stays readable
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.25),
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B6B61),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'NEW ARRIVALS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Featured Artisan\nCollections',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Discover the new seasonal silks directly\nfrom the master weavers of Kathmandu Valley.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: () => ref
                                        .read(currentTabProvider.notifier)
                                        .switchTo(NavTab.search),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white70,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Explore Collection',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final selected = i == _selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = i);
                              // Apply the category and jump to the search/filter tab.
                              ref
                                  .read(productFilterProvider.notifier)
                                  .selectCategory(_categories[i]);
                              ref
                                  .read(currentTabProvider.notifier)
                                  .switchTo(NavTab.search);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1B6B61)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1B6B61)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                _categories[i],
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Trending Textures
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Trending Textures',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => ref
                                .read(currentTabProvider.notifier)
                                .switchTo(NavTab.search),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF1B6B61),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: trending.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final product = trending[i];
                          return _ProductCard(
                            product: product,
                            onTap: () => _openProduct(product),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Meet the Artisans
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Meet the Artisans',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Background image — The Legacy of Dhaka
                            Image.asset(
                              'assets/images/legacy_dhaka_bg.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 200,
                                width: double.infinity,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                            // Dark overlay so the quote stays readable
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 20,
                              bottom: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'The Legacy of Dhaka',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '"Every thread tells a story of our ancestors. We don\'t just weave fabric; we preserve history." — Maya Gurung, Master Weaver for over 40 years.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Fair Trade card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B6B61),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Fair Trade Certified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '100% of our artisans are paid fair, living wages\ndirectly for their craft.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Read Our Impact',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product card

class _ProductCard extends ConsumerStatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  @override
  Widget build(BuildContext context) {
    final isSaved =
        ref.watch(savedProvider).contains(widget.product.id);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: const Color(0xFFD9CFC6),
                    child:
                        (widget.product.imageUrl != null &&
                            widget.product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            widget.product.imageUrl!,
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
                if (widget.product.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.product.badge!.toUpperCase(),
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
                    onTap: () => ref
                        .read(savedProvider.notifier)
                        .toggle(widget.product.id),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved
                          ? const Color(0xFF1B6B61)
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.product.location,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.formattedPrice,
                          style: const TextStyle(
                            color: Color(0xFF1B6B61),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B6B61),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ],
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
