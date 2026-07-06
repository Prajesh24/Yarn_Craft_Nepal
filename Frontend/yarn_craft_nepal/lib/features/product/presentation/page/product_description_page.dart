import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../catalog/domain/entity/product_entity.dart';
import '../../../catalog/presentation/state/cart_state.dart';
import '../../../catalog/presentation/viewmodel/cart_viewmodel.dart';
import '../../../catalog/presentation/viewmodel/product_viewmodel.dart';
import '../../../catalog/presentation/viewmodel/saved_viewmodel.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../order/presentation/viewmodel/order_viewmodel.dart';
import '../../../payment/presentation/page/checkout_page.dart';
import '../viewmodel/review_viewmodel.dart';
import 'review_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductEntity? product;

  const ProductDetailPage({super.key, this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final PageController _imageController = PageController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final FocusNode _qtyFocus = FocusNode();
  int _currentImage = 0;
  int _selectedColor = 0;
  int _qty = 1;

  String get _productName =>
      widget.product?.name ?? 'Pure Dhaka Silk Wrap';

  double get _productPrice => widget.product?.priceNPR ?? 4500.0;

  String get _productLocation =>
      widget.product?.location ?? 'Tehrathum, Nepal';

  String get _productId => widget.product?.id ?? 'default_product';

  int get _stock => widget.product?.stock ?? 24;
  bool get _inStock => _stock > 0;

  String get _batchNo => (widget.product?.batchNo.isNotEmpty ?? false)
      ? widget.product!.batchNo
      : 'YCN-${DateTime.now().year}-000123';

  bool get _verifiedSupplier => widget.product?.verifiedSupplier ?? true;

  /// Related items drawn from the live catalogue: same category first
  /// (excluding the current product), falling back to other products.
  List<ProductEntity> _relatedFrom(List<ProductEntity> all) {
    final others = all.where((p) => p.id != _productId).toList();
    final cat = widget.product?.category;
    final sameCat = (cat == null || cat.isEmpty)
        ? const <ProductEntity>[]
        : others.where((p) => p.category == cat).toList();
    final pool = sameCat.isNotEmpty ? sameCat : others;
    return pool.take(8).toList();
  }

  /// Up to 3 gallery images for this product. The colour swatches map 1:1 to
  /// these, so picking a colour swaps the hero image (and vice-versa).
  List<String> get _gallery {
    final g = widget.product?.gallery ?? const <String>[];
    return g.length > 3 ? g.sublist(0, 3) : g;
  }

  @override
  void dispose() {
    _imageController.dispose();
    _qtyController.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  /// Single entry point for changing the quantity (buttons + text field),
  /// clamped to a minimum of 1 and kept in sync with the text field.
  void _setQty(int value, {bool updateField = true}) {
    final clamped = value < 1 ? 1 : value;
    setState(() => _qty = clamped);
    if (updateField) {
      _qtyController.text = '$clamped';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    }
  }

  /// Jump the hero carousel to [index] (used when a colour is tapped).
  void _showImage(int index) {
    if (index < 0 || index >= _gallery.length) return;
    setState(() {
      _selectedColor = index;
      _currentImage = index;
    });
    if (_imageController.hasClients) {
      _imageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _imagePlaceholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4C4A0), Color(0xFFC8B48A)],
      ),
    ),
    child: const Icon(Icons.texture, color: Colors.white24, size: 80),
  );

  void _addToCart() {
    final gallery = _gallery;
    final image = gallery.isNotEmpty
        ? gallery[_currentImage.clamp(0, gallery.length - 1)]
        : widget.product?.imageUrl;
    final item = CartItem(
      id: _productId,
      name: _productName,
      color: _colorName(_selectedColor),
      size: 'Standard',
      priceNPR: _productPrice,
      quantity: _qty,
      imageUrl: image,
      location: widget.product?.location,
    );
    ref.read(cartProvider.notifier).addItem(item);

    // Capture these now, while `context` is valid. The snackbar (and its
    // action) can outlive this page in the messenger, so the closure must not
    // reach back into this State's context after it may have unmounted.
    final messenger = ScaffoldMessenger.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1B6B61),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => rootNavigator.push(
              MaterialPageRoute(builder: (_) => const CheckoutPage()),
            ),
          ),
        ),
      );
  }

  // Bulk discount

  String _money(double v) =>
      'Rs. ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Widget _bulkDiscountInfo() {
    const threshold = CartState.bulkDiscountThresholdMeters; // 100
    const rate = CartState.bulkDiscountRate; // 0.10
    final qualifies = _qty >= threshold;

    final lineTotal = _productPrice * _qty;
    final discounted = lineTotal * (1 - rate);

    if (qualifies) {
      // Applied state — show the saving and discounted line total.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1B6B61)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer, color: Color(0xFF1B6B61), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bulk discount applied — 10% off!',
                    style: TextStyle(
                      color: Color(0xFF1B6B61),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _money(lineTotal),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _money(discounted),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'You save ${_money(lineTotal - discounted)}',
                  style: const TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Promo state — encourage reaching the threshold.
    final remaining = threshold - _qty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3D9A6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined,
              color: Color(0xFFB45309), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bulk offer: Order $threshold meters or more and get 10% off. '
              'Add $remaining more meter${remaining == 1 ? '' : 's'} to unlock.',
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reviews

  void _openWriteReview() {
    final gallery = _gallery;
    final image = gallery.isNotEmpty ? gallery.first : widget.product?.imageUrl;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WriteReviewPage(
          productId: _productId,
          productName: _productName,
          productImageUrl: image,
        ),
      ),
    );
  }

  Widget _emptyReviews() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          children: [
            Icon(Icons.reviews_outlined, color: Color(0xFF9CA3AF), size: 30),
            SizedBox(height: 8),
            Text(
              'No reviews yet',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Be the first to review this product.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
          ],
        ),
      );

  Widget _reviewsSummary(List<Review> reviews) {
    final avg =
        reviews.fold<int>(0, (s, r) => s + r.rating) / reviews.length;
    return Row(
      children: [
        Text(
          avg.toStringAsFixed(1),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < avg.round() ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFF59E0B),
              size: 18,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '(${reviews.length} review${reviews.length == 1 ? '' : 's'})',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }

  Widget _reviewCard(Review r) {
    final initial = r.author.trim().isNotEmpty
        ? r.author.trim()[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1B6B61),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.author,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      r.formattedDate,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < r.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          if (r.body.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.body,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ],
          if (r.recommends == true) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.thumb_up, color: Color(0xFF1B6B61), size: 13),
                SizedBox(width: 6),
                Text(
                  'Recommends this item',
                  style: TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Colours available for this product (set by the admin). Falls back to a
  /// sensible default set when a product has none, so the section is never empty.
  List<String> get _availableColors {
    final c = widget.product?.colors ?? const <String>[];
    return c.isNotEmpty ? c : const ['White', 'Navy', 'Brown'];
  }

  String _colorName(int idx) {
    final colors = _availableColors;
    if (idx < 0 || idx >= colors.length) return colors.first;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = ref.watch(savedProvider).contains(_productId);
    final allProducts =
        ref.watch(productsProvider).asData?.value ?? const <ProductEntity>[];
    final related = _relatedFrom(allProducts);
    final reviews = ref.watch(reviewsProvider)[_productId] ?? const <Review>[];
    final orders = ref.watch(myOrdersProvider).asData?.value ?? const [];
    final hasPurchased = orders.any(
      (o) => o.items.any((i) => i.productId == _productId),
    );
    final alreadyReviewed = reviews.any(
      (r) => r.author ==
          (ref.read(authViewModelProvider).authEntity?.name ?? ''),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _gallery.isEmpty
                          ? _imagePlaceholder()
                          : PageView.builder(
                              controller: _imageController,
                              itemCount: _gallery.length,
                              onPageChanged: (i) => setState(() {
                                _currentImage = i;
                                // Keep colour selection in sync only when it
                                // maps to a valid colour index.
                                if (i < _availableColors.length) {
                                  _selectedColor = i;
                                }
                              }),
                              itemBuilder: (_, i) => Image.network(
                                _gallery[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _imagePlaceholder(),
                              ),
                            ),

                      // Back button
                      Positioned(
                        top: 48,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF111827),
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // Save button
                      Positioned(
                        top: 48,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(savedProvider.notifier)
                              .toggle(_productId),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isSaved
                                  ? const Color(0xFF1B6B61)
                                  : const Color(0xFF6B7280),
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // Page indicator dots (one per gallery image)
                      if (_gallery.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _gallery.length,
                              (i) => Container(
                                width: i == _currentImage ? 18 : 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: i == _currentImage
                                      ? const Color(0xFF1B6B61)
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _Badge(
                            label: '✓  VERIFIED',
                            bgColor: const Color(0xFF1B6B61),
                            textColor: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            label: '⊛  FAIR TRADE CERTIFIED',
                            bgColor: Colors.white,
                            textColor: const Color(0xFF1B6B61),
                            border: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _productName,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Rs. ${_productPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF1B6B61),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const TextSpan(
                              text: ' per meter',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Qty picker
                      Row(
                        children: [
                          const Text(
                            'QUANTITY',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          _QtyButton(
                            icon: Icons.remove,
                            onTap: () => _setQty(_qty - 1),
                          ),
                          // Editable quantity — type a value or use +/-.
                          Container(
                            width: 56,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _qtyController,
                              focusNode: _qtyFocus,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                                border: InputBorder.none,
                              ),
                              onChanged: (v) {
                                final n = int.tryParse(v) ?? 0;
                                // Update _qty live without rewriting the field
                                // (so the cursor/typing isn't disrupted).
                                if (n >= 1) {
                                  setState(() => _qty = n);
                                }
                              },
                              onEditingComplete: () {
                                // Normalise empty / zero input back to 1.
                                _setQty(int.tryParse(_qtyController.text) ?? 1);
                                _qtyFocus.unfocus();
                              },
                            ),
                          ),
                          _QtyButton(
                            icon: Icons.add,
                            onTap: () => _setQty(_qty + 1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Bulk discount
                      _bulkDiscountInfo(),

                      const SizedBox(height: 20),

                      // Colors
                      Row(
                        children: [
                          const Text(
                            'AVAILABLE COLORS',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _colorName(_selectedColor),
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_availableColors.length, (i) {
                          final selected = i == _selectedColor;
                          final swatch = colorFromName(_availableColors[i]);
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedColor = i);
                              // Swap the hero image to match when a matching
                              // gallery image exists at this index.
                              if (i < _gallery.length) _showImage(i);
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: swatch,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1B6B61)
                                      : const Color(0xFFD1D5DB),
                                  width: selected ? 2.5 : 1,
                                ),
                              ),
                              child: selected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: isLightColor(swatch)
                                          ? const Color(0xFF111827)
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // Features
                      _FeatureRow(
                        icon: _DiagonalIcon(),
                        title: 'Material Breakdown',
                        subtitle: '100% Raw Silk, Hand-spun & Hand-dyed',
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF1B6B61),
                          size: 20,
                        ),
                        title: 'Origin',
                        subtitle: 'Handcrafted in $_productLocation',
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icon(
                          _inStock
                              ? Icons.inventory_2_outlined
                              : Icons.remove_shopping_cart_outlined,
                          color: _inStock
                              ? const Color(0xFF1B6B61)
                              : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        title: 'Availability',
                        subtitle: _inStock
                            ? 'In Stock — $_stock ${_stock == 1 ? 'meter' : 'meters'} available'
                            : 'Out of Stock',
                        subtitleColor: _inStock
                            ? const Color(0xFF1B6B61)
                            : const Color(0xFFDC2626),
                        subtitleWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: const Icon(
                          Icons.qr_code_2,
                          color: Color(0xFF1B6B61),
                          size: 20,
                        ),
                        title: 'Batch No.',
                        subtitle: _batchNo,
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icon(
                          _verifiedSupplier
                              ? Icons.verified
                              : Icons.verified_outlined,
                          color: const Color(0xFF1B6B61),
                          size: 20,
                        ),
                        title: 'Verified Supplier',
                        subtitle: _verifiedSupplier
                            ? 'Quality-checked & authenticity verified'
                            : 'Verification pending',
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // Ratings & Reviews
                      const Text(
                        'Ratings & Reviews',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (reviews.isEmpty)
                        _emptyReviews()
                      else ...[
                        _reviewsSummary(reviews),
                        const SizedBox(height: 12),
                        ...reviews.map(_reviewCard),
                      ],

                      const SizedBox(height: 12),

                      // Add Your Review — only for buyers who haven't reviewed yet
                      if (hasPurchased && !alreadyReviewed)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openWriteReview,
                            icon: const Icon(Icons.rate_review_outlined, size: 18),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B6B61),
                              side: const BorderSide(color: Color(0xFF1B6B61)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            label: const Text(
                              'Add Your Review',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else if (alreadyReviewed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD1EAE6)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Color(0xFF1B6B61), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'You have already reviewed this product',
                                style: TextStyle(
                                  color: Color(0xFF1B6B61),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!hasPurchased)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  color: Color(0xFF9CA3AF), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Purchase this product to leave a review',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      if (related.isNotEmpty) ...[
                        const Text(
                          'Related Products',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: related.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final p = related[i];
                              return GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailPage(product: p),
                                  ),
                                ),
                                child: Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F0EA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            color: const Color(0xFFD6C8B5),
                                            child:
                                                (p.imageUrl != null &&
                                                    p.imageUrl!.isNotEmpty)
                                                ? Image.network(
                                                    p.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, _, _) => const Icon(
                                                          Icons.texture,
                                                          color: Colors.white38,
                                                          size: 32,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.texture,
                                                    color: Colors.white38,
                                                    size: 32,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              p.formattedPrice,
                                              style: const TextStyle(
                                                color: Color(0xFF1B6B61),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Add to Cart
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B61),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Badge

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor, textColor;
  final bool border;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: border
          ? Border.all(color: const Color(0xFF1B6B61), width: 1)
          : null,
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );
}

// Feature row

class _FeatureRow extends StatelessWidget {
  final Widget icon;
  final String title, subtitle;
  final Color? subtitleColor;
  final FontWeight subtitleWeight;
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.subtitleWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 28, child: icon),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: subtitleColor ?? const Color(0xFF6B7280),
                fontSize: 12,
                height: 1.4,
                fontWeight: subtitleWeight,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Qty button

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF374151)),
    ),
  );
}

// Diagonal stripe icon

class _DiagonalIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 20, height: 20, child: CustomPaint(painter: _StripePainter()));
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1B6B61)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), p);
    canvas.drawLine(
      Offset(size.width * 0.4, size.height),
      Offset(size.width, size.height * 0.2),
      p,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.6, 0),
      p,
    );
  }

  @override
  bool shouldRepaint(_StripePainter _) => false;
}
