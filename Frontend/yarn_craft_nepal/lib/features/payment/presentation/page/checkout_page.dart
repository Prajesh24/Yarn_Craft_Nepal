import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/viewmodel/cart_viewmodel.dart';
import 'payment_method_page.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedCity;
  bool _summaryExpanded = true;

  final List<String> _cities = const [
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Pokhara',
    'Chitwan',
    'Biratnagar',
    'Butwal',
    'Dharan',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your city.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodPage()),
    );
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
                        'Checkout',
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
                child: Column(
                  children: [
                    // Delivery info card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Information',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Full Name
                            const _Label('Full Name'),
                            const SizedBox(height: 6),
                            _Field(
                              controller: _nameCtrl,
                              hint: 'Enter your full name',
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Enter your name.'
                                      : null,
                            ),

                            const SizedBox(height: 14),

                            // Phone
                            const _Label('Phone Number'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: const Text(
                                    '+977',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _Field(
                                    controller: _phoneCtrl,
                                    hint: '98XXXXXXXX',
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (v) =>
                                        v == null || v.trim().length < 10
                                            ? 'Enter a valid phone number.'
                                            : null,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Delivery Address
                            const _Label('Delivery Address'),
                            const SizedBox(height: 6),
                            _Field(
                              controller: _addressCtrl,
                              hint:
                                  'Street address, neighborhood, landmark...',
                              maxLines: 3,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Enter your address.'
                                      : null,
                            ),

                            const SizedBox(height: 14),

                            // City dropdown
                            const _Label('City / Region'),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCity,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Select your city',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF6B7280),
                                    size: 22,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                  ),
                                  items: _cities
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCity = v),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Special Instructions
                            Row(
                              children: const [
                                _Label('Special Instructions'),
                                SizedBox(width: 6),
                                Text(
                                  '(Optional)',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _Field(
                              controller: _notesCtrl,
                              hint:
                                  'Any specific delivery instructions or preferences?',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Order Summary card — uses real cart data
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          // Header row
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
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _summaryExpanded = !_summaryExpanded,
                                ),
                                child: Icon(
                                  _summaryExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF6B7280),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),

                          // Item list (collapsible)
                          if (_summaryExpanded) ...[
                            const SizedBox(height: 14),
                            ...cart.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        color: const Color(0xFF1B6B61)
                                            .withValues(alpha: 0.15),
                                        child: (item.imageUrl != null &&
                                                item.imageUrl!.isNotEmpty)
                                            ? Image.network(
                                                item.imageUrl!,
                                                width: 52,
                                                height: 52,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    const Icon(
                                                  Icons.texture,
                                                  color: Color(0xFF1B6B61),
                                                  size: 22,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.texture,
                                                color: Color(0xFF1B6B61),
                                                size: 22,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: Color(0xFF111827),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.formattedPrice,
                                            style: const TextStyle(
                                              color: Color(0xFF111827),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Subtotal',
                            value: cart.formattedSubtotal,
                          ),
                          if (cart.qualifiesForBulkDiscount) ...[
                            const SizedBox(height: 6),
                            _PriceRow(
                              label: 'Bulk Discount (10%)',
                              value: cart.formattedDiscount,
                              highlight: true,
                            ),
                          ],
                          const SizedBox(height: 6),
                          _PriceRow(
                            label: 'Delivery Fee',
                            value: cart.formattedDeliveryFee,
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Total',
                            value: cart.formattedTotal,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    // Confirm button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _proceedToPayment,
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
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Text(
                        'By confirming, you agree to our Terms of Service.',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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

// Field label

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF374151),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

// Text field

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboard =
        maxLines > 1 ? TextInputType.multiline : keyboardType;
    final effectiveAction =
        maxLines > 1 ? TextInputAction.newline : TextInputAction.next;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: effectiveKeyboard,
      textInputAction: effectiveAction,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF1B6B61),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 11,
        ),
      ),
    );
  }
}

// Price row

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  final bool highlight;

  const _PriceRow({
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
          fontWeight:
              (isTotal || highlight) ? FontWeight.w700 : FontWeight.w400,
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
