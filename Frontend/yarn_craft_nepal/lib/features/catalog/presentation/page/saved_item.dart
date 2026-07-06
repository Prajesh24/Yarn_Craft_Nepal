import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/catalog/domain/entity/product_entity.dart';
import '../../../../features/product/presentation/page/product_description_page.dart';
import '../viewmodel/cart_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../viewmodel/saved_viewmodel.dart';
import '../state/cart_state.dart';

class SavedItemsPage extends ConsumerWidget {
  const SavedItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedProvider);
    // Resolve the saved ids against the live product catalogue.
    final products =
        ref.watch(productsProvider).asData?.value ?? const <ProductEntity>[];
    final saved = products.where((p) => savedIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'YarnCraft Nepal',
                        style: TextStyle(
                          color: Color(0xFF1B6B61),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Favorites',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You have ${saved.length} item${saved.length == 1 ? '' : 's'} saved.',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid or empty state
            Expanded(
              child: saved.isEmpty
                  ? _EmptySaved()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      // Responsive: column count adapts to screen width.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: saved.length,
                      itemBuilder: (_, i) {
                        final product = saved[i];
                        return _SavedCard(
                          product: product,
                          onUnsave: () => ref
                              .read(savedProvider.notifier)
                              .toggle(product.id),
                          onAddToCart: () {
                            ref.read(cartProvider.notifier).addItem(
                                  CartItem(
                                    id: product.id,
                                    name: product.name,
                                    priceNPR: product.priceNPR,
                                    imageUrl: product.imageUrl,
                                    location: product.location,
                                  ),
                                );
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFF1B6B61),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                          },
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          ),
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

// Empty state

class _EmptySaved extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.favorite_border,
          color: Color(0xFFD1D5DB),
          size: 72,
        ),
        SizedBox(height: 16),
        Text(
          'No saved items yet',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap the heart on any product\nto save it here.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// Saved card

class _SavedCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onUnsave, onAddToCart, onTap;

  const _SavedCard({
    required this.product,
    required this.onUnsave,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
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
          // Image with badge + filled heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  height: 120,
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
                      color: product.badgeColor,
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
                  onTap: onUnsave,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF1B6B61),
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Add to Cart button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton.icon(
                onPressed: onAddToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B6B61),
                  side: const BorderSide(color: Color(0xFF1B6B61)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 13),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
