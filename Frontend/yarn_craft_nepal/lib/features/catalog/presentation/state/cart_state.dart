import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final String color;
  final String size;
  final double priceNPR;
  final int quantity;
  final String? imageUrl;
  final String? location;

  const CartItem({
    required this.id,
    required this.name,
    this.color = 'Default',
    this.size = 'Standard',
    required this.priceNPR,
    this.quantity = 1,
    this.imageUrl,
    this.location,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    name: name,
    color: color,
    size: size,
    priceNPR: priceNPR,
    quantity: quantity ?? this.quantity,
    imageUrl: imageUrl,
    location: location,
  );

  /// Country of origin badge text derived from [location]
  /// (e.g. "Pokhara Valley" → Nepal, "Jaipur, India" → India).
  String get madeIn {
    final loc = (location ?? '').toLowerCase();
    if (loc.contains('india')) return 'Made in India';
    return 'Made in Nepal';
  }

  String get formattedPrice =>
      'NPR ${priceNPR.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  List<Object?> get props =>
      [id, name, color, size, priceNPR, quantity, imageUrl, location];
}

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  /// Bulk discount: 10% off when the order is 100 meters or more (total qty).
  static const int bulkDiscountThresholdMeters = 100;
  static const double bulkDiscountRate = 0.10;

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => items.fold(0.0, (s, i) => s + i.priceNPR * i.quantity);

  /// True when the total ordered length qualifies for the bulk discount.
  bool get qualifiesForBulkDiscount =>
      totalItems >= bulkDiscountThresholdMeters;

  /// Discount amount (10% of subtotal) when the order qualifies, else 0.
  double get discount =>
      qualifiesForBulkDiscount ? subtotal * bulkDiscountRate : 0.0;

  double get deliveryFee => items.isEmpty ? 0.0 : 150.0;
  double get total => subtotal - discount + deliveryFee;
  bool get isEmpty => items.isEmpty;

  String get formattedSubtotal =>
      'NPR ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedDiscount =>
      '- NPR ${discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedDeliveryFee =>
      'NPR ${deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedTotal =>
      'NPR ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
