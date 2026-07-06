/// A single line item within an order.
class OrderItemEntity {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? color;
  final String? size;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.color,
    this.size,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    return OrderItemEntity(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? 'Item').toString(),
      price: price is num ? price.toDouble() : double.tryParse('$price') ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
    );
  }
}

/// A placed order as returned by the backend (`/api/v1/orders`).
class OrderEntity {
  final String id;
  final String orderNumber;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String status; // processing | inTransit | delivered | cancelled
  final DateTime? createdAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
  });

  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

    final rawItems = (json['items'] as List?) ?? const [];
    return OrderEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemEntity.fromJson)
          .toList(),
      subtotal: toD(json['subtotal']),
      deliveryFee: toD(json['deliveryFee']),
      total: toD(json['total']),
      paymentMethod: (json['paymentMethod'] ?? 'cashOnDelivery').toString(),
      status: (json['status'] ?? 'processing').toString(),
      createdAt: DateTime.tryParse('${json['createdAt']}')?.toLocal(),
    );
  }
}
