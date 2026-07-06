import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../viewmodel/review_viewmodel.dart';

class WriteReviewPage extends ConsumerStatefulWidget {
  /// Pass the product details from the product detail page.
  final String productId;
  final String productName;
  final String orderedDate;
  final String? productImageUrl; // network URL of the product image

  const WriteReviewPage({
    super.key,
    this.productId = 'default_product',
    this.productName = 'Pure Dhaka Silk Wrap',
    this.orderedDate = 'Oct 24, 2023',
    this.productImageUrl,
  });

  @override
  ConsumerState<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends ConsumerState<WriteReviewPage> {
  int _rating = 4; // 1-5
  bool? _recommends; // null = not yet chosen
  final _reviewCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  // Submit

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final authorName =
        ref.read(authViewModelProvider).authEntity?.name.trim();

    await ref.read(reviewsProvider.notifier).addReview(
          Review(
            productId: widget.productId,
            author: (authorName != null && authorName.isNotEmpty)
                ? authorName
                : 'You',
            rating: _rating,
            body: _reviewCtrl.text.trim(),
            recommends: _recommends,
            date: DateTime.now(),
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Review submitted! Thank you.'),
          backgroundColor: Color(0xFF1B6B61),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1B6B61),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Write your Review',
                          style: TextStyle(
                            color: Color(0xFF1B6B61),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Product card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (widget.productImageUrl != null &&
                                    widget.productImageUrl!.isNotEmpty)
                                ? Image.network(
                                    widget.productImageUrl!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 64,
                                      height: 64,
                                      color: const Color(0xFF3D0D0D),
                                      child: const Icon(
                                        Icons.texture,
                                        color: Colors.white30,
                                        size: 26,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF6B1A1A),
                                          Color(0xFF3D0D0D),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.texture,
                                      color: Colors.white30,
                                      size: 26,
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 14),

                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productName,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ordered: ${widget.orderedDate}',
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Star rating
                    const Center(
                      child: Text(
                        'How was your experience?',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Tap to rate the overall product',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stars
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          final filled = i < _rating;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: filled
                                    ? const Color(0xFFB7791F)
                                    : const Color(0xFFD1D5DB),
                                size: 44,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Star label
                    if (_rating > 0) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _ratingLabel(_rating),
                          style: const TextStyle(
                            color: Color(0xFFB7791F),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Review text
                    const Text(
                      'Share your experience',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _reviewCtrl,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          height: 1.55,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Tell other crafters about the drape, weight, '
                              'and how you plan to use this silk...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            height: 1.55,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1B6B61),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recommend this item?
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_outlined,
                            color: Color(0xFF1B6B61),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Recommend this item?',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Yes button
                          _RecommendButton(
                            label: 'Yes',
                            selected: _recommends == true,
                            onTap: () => setState(
                              () => _recommends = _recommends == true
                                  ? null
                                  : true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // No button
                          _RecommendButton(
                            label: 'No',
                            selected: _recommends == false,
                            onTap: () => setState(
                              () => _recommends = _recommends == false
                                  ? null
                                  : false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Submit button
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE5E7EB).withOpacity(0.8),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B61),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 15,
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

  String _ratingLabel(int r) => switch (r) {
    1 => 'Poor',
    2 => 'Fair',
    3 => 'Good',
    4 => 'Very Good',
    5 => 'Excellent',
    _ => '',
  };
}

// Recommend Yes / No button

class _RecommendButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecommendButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B6B61) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1B6B61) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
