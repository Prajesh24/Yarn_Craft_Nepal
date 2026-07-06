import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/viewmodel/cart_viewmodel.dart';
import '../../../order/presentation/viewmodel/order_viewmodel.dart';
import 'esewa_payment_page.dart';
import 'order_success.dart';

enum PaymentOption { cashOnDelivery, payOnline }

class PaymentMethodPage extends ConsumerStatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  PaymentOption _selected = PaymentOption.cashOnDelivery;
  bool _placing = false;

  Future<void> _confirmOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    // For online payment, run the (demo) eSewa flow first. Only proceed to
    // place the order if the payment is confirmed.
    if (_selected == PaymentOption.payOnline) {
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => EsewaPaymentPage(amount: cart.total),
        ),
      );
      if (!mounted) return;
      if (paid != true) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Payment was not completed.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }
    }

    setState(() => _placing = true);

    final items = cart.items
        .map(
          (i) => {
            'productId': i.id,
            'name': i.name,
            'price': i.priceNPR,
            'quantity': i.quantity,
            'color': i.color,
            'size': i.size,
            if (i.imageUrl != null && i.imageUrl!.isNotEmpty)
              'imageUrl': i.imageUrl,
          },
        )
        .toList();

    try {
      await ref
          .read(orderActionsProvider)
          .placeOrder(
            items: items,
            subtotal: cart.subtotal,
            deliveryFee: cart.deliveryFee,
            total: cart.total,
            paymentMethod: _selected == PaymentOption.cashOnDelivery
                ? 'cashOnDelivery'
                : 'payOnline',
          );

      if (!mounted) return;

      // Clear cart only after the order is successfully persisted.
      ref.read(cartProvider.notifier).clearCart();
      setState(() => _placing = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place order: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                color: Color(0xFF1B6B61),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Payment Method',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _PaymentOption(
                            value: PaymentOption.cashOnDelivery,
                            grouped: _selected,
                            title: 'Cash on Delivery',
                            subtitle: 'Pay when you receive your order',
                            onChanged: (v) =>
                                setState(() => _selected = v!),
                          ),

                          const SizedBox(height: 10),

                          _PaymentOption(
                            value: PaymentOption.payOnline,
                            grouped: _selected,
                            title: 'Pay Online with eSewa',
                            subtitle: 'Pay securely using your eSewa wallet',
                            onChanged: (v) =>
                                setState(() => _selected = v!),
                          ),

                          // eSewa hint when Pay Online selected
                          if (_selected == PaymentOption.payOnline) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCDE8C2),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF60BB46),
                                    size: 30,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Continue with eSewa',
                                          style: TextStyle(
                                            color: Color(0xFF3D8E2C),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'You\'ll be taken to the eSewa screen to complete payment when you confirm.',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 11,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Order Summary — real cart data
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5F3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${cart.items.length} Item${cart.items.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    color: Color(0xFF1B6B61),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _SummaryRow(
                            label: 'Subtotal',
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
                            label: 'Delivery Fee',
                            value: cart.formattedDeliveryFee,
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Total',
                            value: cart.formattedTotal,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _placing ? null : _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B6B61),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _placing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Confirm Order Request',
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

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        'By confirming, you agree to our Terms of Service.',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),
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

// Payment option tile

class _PaymentOption extends StatelessWidget {
  final PaymentOption value, grouped;
  final String title, subtitle;
  final ValueChanged<PaymentOption?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.grouped,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == grouped;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0F9F7)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF1B6B61)
                : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<PaymentOption>(
              value: value,
              groupValue: grouped,
              onChanged: onChanged,
              activeColor: const Color(0xFF1B6B61),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFF374151),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Summary row

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          color: highlight
              ? const Color(0xFF1B6B61)
              : isTotal
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
          fontSize: isTotal ? 15 : 13,
          fontWeight: (isTotal || highlight)
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: (isTotal || highlight)
              ? const Color(0xFF1B6B61)
              : const Color(0xFF111827),
          fontSize: isTotal ? 16 : 13,
          fontWeight: isTotal
              ? FontWeight.w800
              : highlight
                  ? FontWeight.w700
                  : FontWeight.w500,
        ),
      ),
    ],
  );
}
