import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A single product review written by a user.
class Review {
  final String productId;
  final String author;
  final int rating; // 1–5
  final String body;
  final bool? recommends;
  final DateTime date;

  const Review({
    required this.productId,
    required this.author,
    required this.rating,
    required this.body,
    this.recommends,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'author': author,
        'rating': rating,
        'body': body,
        'recommends': recommends,
        'date': date.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        productId: json['productId'] as String? ?? '',
        author: json['author'] as String? ?? 'Anonymous',
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        body: json['body'] as String? ?? '',
        recommends: json['recommends'] as bool?,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      );

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get formattedDate => '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

const String _reviewsBoxName = 'reviews_box';

/// Holds reviews keyed by productId, persisted in Hive so they survive restarts.
final reviewsProvider =
    NotifierProvider<ReviewsNotifier, Map<String, List<Review>>>(
  ReviewsNotifier.new,
);

class ReviewsNotifier extends Notifier<Map<String, List<Review>>> {
  /// Open the Hive box once during app start-up (after HiveService.init()).
  static Future<void> init() async {
    await Hive.openBox<dynamic>(_reviewsBoxName);
  }

  Box<dynamic> get _box => Hive.box<dynamic>(_reviewsBoxName);

  @override
  Map<String, List<Review>> build() {
    final raw = _box.get('all') as String?;
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          (value as List)
              .map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  /// Reviews for a product, newest first.
  List<Review> forProduct(String productId) => state[productId] ?? const [];

  Future<void> addReview(Review review) async {
    final map = {...state};
    map[review.productId] = [review, ...(map[review.productId] ?? const [])];
    state = map;
    await _persist();
  }

  Future<void> _persist() async {
    final encodable = state.map(
      (key, value) => MapEntry(key, value.map((r) => r.toJson()).toList()),
    );
    await _box.put('all', jsonEncode(encodable));
  }
}
