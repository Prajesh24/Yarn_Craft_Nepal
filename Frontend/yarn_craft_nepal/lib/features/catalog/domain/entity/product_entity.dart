import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final double priceNPR;
  final String? badge;
  final Color? badgeColor;
  final String? imageUrl;
  final String category;

  /// Available stock (mapped from the backend `quantity`).
  final int stock;

  /// Manufacturing batch / lot number shown on the product page.
  final String batchNo;

  /// Whether the supplier is verified (quality-checked). Defaults to true for
  /// the curated catalogue.
  final bool verifiedSupplier;

  /// Up to a few gallery images (resolved absolute URLs). Falls back to
  /// [imageUrl] when the backend doesn't provide a list.
  final List<String> images;

  /// Available colour names for this product, set by the admin
  /// (e.g. ['White', 'Navy', 'Brown']).
  final List<String> colors;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.priceNPR,
    this.badge,
    this.badgeColor,
    this.imageUrl,
    this.category = 'Other',
    this.stock = 0,
    this.batchNo = '',
    this.verifiedSupplier = true,
    this.images = const [],
    this.colors = const [],
  });

  bool get inStock => stock > 0;

  /// Convenience: the gallery, guaranteed non-empty when any image exists.
  List<String> get gallery {
    if (images.isNotEmpty) return images;
    if (imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    return const [];
  }

  String get formattedPrice =>
      'Rs. ${priceNPR.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    priceNPR,
    badge,
    badgeColor,
    imageUrl,
    category,
    stock,
    batchNo,
    verifiedSupplier,
    images,
    colors,
  ];
}
