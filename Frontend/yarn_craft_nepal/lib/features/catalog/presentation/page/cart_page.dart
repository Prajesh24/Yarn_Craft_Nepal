import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../features/payment/presentation/page/checkout_page.dart';
import '../state/cart_state.dart';
import '../viewmodel/cart_viewmodel.dart';
import '../viewmodel/tab_viewmodel.dart';
import 'yarn_bottom_nav.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: const Center(
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

            // Body
            Expanded(
              child: cart.isEmpty
                  ? _EmptyCart(
                      onContinue: () => ref
                          .read(currentTabProvider.notifier)
                          .switchTo(NavTab.home),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Cart',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Artisan support banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9F7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFD1EAE6),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: Color(0xFF1B6B61),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'You are supporting ${cart.totalItems} local artisan${cart.totalItems == 1 ? '' : 's'} with this order.',
                                  style: const TextStyle(
                                    color: Color(0xFF1B6B61),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Cart items
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartItemCard(
                                item: item,
                                onDelete: () => ref
                                    .read(cartProvider.notifier)
                                    .removeItem(item.id),
                                onIncrease: () => ref
                                    .read(cartProvider.notifier)
                                    .increaseQty(item.id),
                                onDecrease: () => ref
                                    .read(cartProvider.notifier)
                                    .decreaseQty(item.id),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Order Summary
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _SummaryRow(
                            label:
                                'Subtotal (${cart.totalItems} meter${cart.totalItems == 1 ? '' : 's'})',
                            value: cart.formattedSubtotal,
                          ),
                          if (cart.qualifiesForBulkDiscount) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Bulk Discount (10%)',
                              value: cart.formattedDiscount,
                              highlight: true,
                            ),
                          ],
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Estimated Shipping',
                            value: cart.formattedDeliveryFee,
                            multiLine: true,
                          ),
                          const SizedBox(height: 8),
                          const _SummaryRow(
                            label: 'Artisan Support Contribution',
                            value: 'Included',
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 12),

                          // Total
                          Row(
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                cart.formattedTotal,
                                style: const TextStyle(
                                  color: Color(0xFF1B6B61),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Proceed button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutPage(),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B6B61),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Proceed to Checkout',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
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

// Empty cart state

class _EmptyCart extends StatelessWidget {
  final VoidCallback onContinue;

  const _EmptyCart({required this.onContinue});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.shopping_cart_outlined,
          color: Color(0xFFD1D5DB),
          size: 72,
        ),
        const SizedBox(height: 16),
        const Text(
          'Your cart is empty',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Browse our artisan collections\nand add items you love.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: onContinue,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1B6B61),
            side: const BorderSide(color: Color(0xFF1B6B61)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            minimumSize: Size.zero,
          ),
          child: const Text(
            'Continue Shopping',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// Cart item card

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete, onIncrease, onDecrease;

  const _CartItemCard({
    required this.item,
    required this.onDelete,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 70,
            height: 70,
            color: const Color(0xFF3D2B1F),
            child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                ? Image.network(
                    item.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.texture,
                      color: Colors.white30,
                      size: 28,
                    ),
                  )
                : const Icon(Icons.texture, color: Colors.white30, size: 28),
          ),
        ),

        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Selected colour swatch + colour name + size
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorFromName(item.color),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item.color} | Size: ${item.size}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Trust badges — country of origin + verified supplier
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _TrustBadge(
                    icon: Icons.public,
                    label: item.madeIn,
                  ),
                  const _TrustBadge(
                    icon: Icons.verified,
                    label: 'Verified Supplier',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _QtyButton(icon: Icons.remove, onTap: onDecrease),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _QtyButton(icon: Icons.add, onTap: onIncrease),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Trust badge (origin / verified supplier)

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F9F7),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFD1EAE6)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF1B6B61)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1B6B61),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: const Color(0xFF374151)),
    ),
  );
}

// Summary row

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool multiLine;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.multiLine = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment:
        multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: highlight ? const Color(0xFF1B6B61) : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        value,
        style: TextStyle(
          color: highlight ? const Color(0xFF1B6B61) : const Color(0xFF111827),
          fontSize: 13,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
        ),
        textAlign: TextAlign.right,
      ),
    ],
  );
}
