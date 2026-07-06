import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../order/domain/order_entity.dart';
import '../../../order/presentation/viewmodel/order_viewmodel.dart';
import 'review_page.dart';

// Order status

enum OrderStatus { inTransit, delivered, processing, cancelled }

extension OrderStatusExt on OrderStatus {
  String get label => switch (this) {
    OrderStatus.inTransit => 'In Transit',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.processing => 'Processing',
    OrderStatus.cancelled => 'Cancelled',
  };

  Color get bgColor => switch (this) {
    OrderStatus.inTransit => const Color(0xFFFEF3C7),
    OrderStatus.delivered => const Color(0xFF1B6B61),
    OrderStatus.processing => const Color(0xFFF3F4F6),
    OrderStatus.cancelled => const Color(0xFFFEE2E2),
  };

  Color get textColor => switch (this) {
    OrderStatus.inTransit => const Color(0xFFB45309),
    OrderStatus.delivered => Colors.white,
    OrderStatus.processing => const Color(0xFF6B7280),
    OrderStatus.cancelled => const Color(0xFFDC2626),
  };

  IconData get icon => switch (this) {
    OrderStatus.inTransit => Icons.local_shipping_outlined,
    OrderStatus.delivered => Icons.check_circle_outline,
    OrderStatus.processing => Icons.sync,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };

  bool get isOngoing =>
      this == OrderStatus.inTransit || this == OrderStatus.processing;
}

// Order model

class OrderModel {
  final String backendId; // real Mongo _id, used for cancel API
  final String id;
  final String placedOn;
  final OrderStatus status;
  final String itemIcon; // fallback icon key when no image is available
  final String? itemImageUrl; // resolved network image of the first item
  final String itemName;
  final String itemDetail;
  final String price;
  final String? deliveryNote; // e.g. "Estimated Delivery: Oct 28"
  final String? actionLabel; // button label
  final String? actionNote; // italic note below item
  final bool canCancel;
  final bool canMarkReceived;
  final bool canReview;

  // First item details — used to open the review page for a delivered order.
  final String reviewProductId;
  final String reviewProductName;
  final String? reviewProductImageUrl;

  const OrderModel({
    this.backendId = '',
    required this.id,
    required this.placedOn,
    required this.status,
    required this.itemIcon,
    this.itemImageUrl,
    required this.itemName,
    required this.itemDetail,
    required this.price,
    this.deliveryNote,
    this.actionLabel,
    this.actionNote,
    this.canCancel = false,
    this.canMarkReceived = false,
    this.canReview = false,
    this.reviewProductId = '',
    this.reviewProductName = '',
    this.reviewProductImageUrl,
  });
}

// Page

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  int _tab = 0; // 0=All, 1=Ongoing, 2=Delivered

  List<OrderModel> _filtered(List<OrderModel> all) => switch (_tab) {
    1 => all.where((o) => o.status.isOngoing).toList(),
    2 => all.where((o) => o.status == OrderStatus.delivered).toList(),
    _ => all,
  };

  // Map a backend order to the display model
  OrderStatus _statusFrom(String s) => switch (s) {
    'inTransit' => OrderStatus.inTransit,
    'delivered' => OrderStatus.delivered,
    'cancelled' => OrderStatus.cancelled,
    _ => OrderStatus.processing,
  };

  String _formatDate(DateTime? d) {
    if (d == null) return 'Recently placed';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Placed on ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _money(double v) =>
      'Rs.\n${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  /// Turns a stored image path (absolute URL or relative `/uploads/...`)
  /// into an absolute URL the review page can load.
  String? _resolveImage(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) return null;
    return s.startsWith('http') ? s : '${ApiEndpoints.serverOrigin}$s';
  }

  // Open the review page for a delivered order's item
  void _openReview(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WriteReviewPage(
          productId: order.reviewProductId,
          productName: order.reviewProductName,
          productImageUrl: order.reviewProductImageUrl,
          orderedDate: order.placedOn,
        ),
      ),
    );
  }

  OrderModel _toModel(OrderEntity e) {
    final status = _statusFrom(e.status);
    final first = e.items.isNotEmpty ? e.items.first : null;
    final extra = e.items.length - 1;

    final detail = e.items.length <= 1
        ? [
            'Qty: ${first?.quantity ?? 1}',
            if (first?.size != null && first!.size!.isNotEmpty) first.size,
            if (first?.color != null && first!.color!.isNotEmpty) first.color,
          ].join(' • ')
        : '${e.items.length} items • ${e.totalQuantity} pcs';

    String? deliveryNote;
    String? actionLabel;
    String? actionNote;
    switch (status) {
      case OrderStatus.delivered:
        deliveryNote = 'Delivered';
        break;
      case OrderStatus.inTransit:
        deliveryNote = 'Estimated Delivery: 3–5 days';
        break;
      case OrderStatus.processing:
        actionNote = 'We\'re preparing your items';
        actionLabel = 'Cancel Order';
        break;
      case OrderStatus.cancelled:
        actionNote = 'This order was cancelled';
        break;
    }

    return OrderModel(
      backendId: e.id,
      id: '#${e.orderNumber}',
      placedOn: _formatDate(e.createdAt),
      status: status,
      itemIcon: 'bag',
      itemImageUrl: _resolveImage(first?.imageUrl),
      itemName: extra > 0 ? '${first?.name ?? 'Order'} +$extra more' : (first?.name ?? 'Order'),
      itemDetail: detail,
      price: _money(e.total),
      deliveryNote: deliveryNote,
      actionLabel: actionLabel,
      actionNote: actionNote,
      canCancel: status == OrderStatus.processing,
      // A user can confirm delivery on any ongoing order (processing/in-transit).
      canMarkReceived: status.isOngoing,
      // Once delivered, the user can leave a review for the purchased item.
      canReview: status == OrderStatus.delivered && first != null,
      reviewProductId: first?.productId ?? '',
      reviewProductName: first?.name ?? '',
      reviewProductImageUrl: _resolveImage(first?.imageUrl),
    );
  }

  // Mark as received dialog
  void _showReceivedDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Receipt',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Confirm that you have received order ${order.id}? This will mark it as delivered.',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Not Yet',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(orderActionsProvider)
                    .markReceived(order.backendId);
                messenger
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                    content: Text('Order ${order.id} marked as received.'),
                    backgroundColor: const Color(0xFF1B6B61),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
              } catch (e) {
                messenger
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                    content: Text('Could not update order: $e'),
                    behavior: SnackBarBehavior.floating,
                  ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B6B61),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Yes, Received'),
          ),
        ],
      ),
    );
  }

  // Item icon mapper
  IconData _iconFor(String key) => switch (key) {
    'shirt' => Icons.checkroom_outlined,
    'weave' => Icons.texture,
    'bag' => Icons.shopping_bag_outlined,
    _ => Icons.inventory_2_outlined,
  };

  // Cancel dialog
  void _showCancelDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel order ${order.id}?',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(orderActionsProvider)
                    .cancelOrder(order.backendId);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Order ${order.id} cancelled.'),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Could not cancel order: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Cancel Order',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

            // Heading + tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order History',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab row
                  Row(
                    children: [
                      _Tab(
                        label: 'All Orders',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      const SizedBox(width: 8),
                      _Tab(
                        label: 'Ongoing',
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      const SizedBox(width: 8),
                      _Tab(
                        label: 'Delivered',
                        selected: _tab == 2,
                        onTap: () => setState(() => _tab = 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Order list
            Expanded(
              child: ref
                  .watch(myOrdersProvider)
                  .when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B6B61),
                      ),
                    ),
                    error: (e, _) => _ErrorState(
                      onRetry: () => ref.invalidate(myOrdersProvider),
                    ),
                    data: (orders) {
                      final all = orders.map(_toModel).toList();
                      final filtered = _filtered(all);
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'No orders found.',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        color: const Color(0xFF1B6B61),
                        onRefresh: () async =>
                            ref.invalidate(myOrdersProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _OrderCard(
                            order: filtered[i],
                            iconData: _iconFor(filtered[i].itemIcon),
                            onAction: () {
                              if (filtered[i].canCancel) {
                                _showCancelDialog(filtered[i]);
                              }
                            },
                            onMarkReceived: filtered[i].canMarkReceived
                                ? () => _showReceivedDialog(filtered[i])
                                : null,
                            onReview: filtered[i].canReview
                                ? () => _openReview(filtered[i])
                                : null,
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

// Error state

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, color: Color(0xFFD1D5DB), size: 56),
        const SizedBox(height: 12),
        const Text(
          'Couldn\'t load your orders',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRetry,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1B6B61),
            side: const BorderSide(color: Color(0xFF1B6B61)),
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

// Tab chip

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B6B61) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1B6B61) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Order card

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final IconData iconData;
  final VoidCallback onAction;
  final VoidCallback? onMarkReceived;
  final VoidCallback? onReview;

  const _OrderCard({
    required this.order,
    required this.iconData,
    required this.onAction,
    this.onMarkReceived,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.id}',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.placedOn,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, color: status.textColor, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        status.label,
                        style: TextStyle(
                          color: status.textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xFFE5E7EB), height: 1),
            const SizedBox(height: 14),

            // Item row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item thumbnail — actual product image, icon as fallback
                Container(
                  width: 52,
                  height: 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: (order.itemImageUrl != null &&
                          order.itemImageUrl!.isNotEmpty)
                      ? Image.network(
                          order.itemImageUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            iconData,
                            color: const Color(0xFF9CA3AF),
                            size: 22,
                          ),
                        )
                      : Icon(
                          iconData,
                          color: const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                ),

                const SizedBox(width: 12),

                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemName,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.itemDetail,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Price
                Text(
                  order.price,
                  style: const TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),

            // Delivery note
            if (order.deliveryNote != null) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 12),
              _DeliveryNote(note: order.deliveryNote!),
            ],

            // Processing note (italic)
            if (order.actionNote != null) ...[
              const SizedBox(height: 10),
              Text(
                order.actionNote!,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Action buttons row
            if (order.actionLabel != null || onMarkReceived != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (order.actionLabel != null) ...[
                    _ActionButton(
                      label: order.actionLabel!,
                      canCancel: order.canCancel,
                      onTap: onAction,
                    ),
                    if (onMarkReceived != null) const SizedBox(width: 10),
                  ],
                  if (onMarkReceived != null)
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: onMarkReceived,
                          icon: const Icon(Icons.check_circle_outline, size: 15),
                          label: const Text(
                            'Mark as Received',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6B61),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // Write a review (delivered orders)
            if (onReview != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B6B61),
                    side: const BorderSide(color: Color(0xFF1B6B61)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Delivery note row

class _DeliveryNote extends StatelessWidget {
  final String note;
  const _DeliveryNote({required this.note});

  @override
  Widget build(BuildContext context) {
    // Split at the date portion (last word/s after colon) to bold it
    final parts = note.split(':');
    if (parts.length < 2) {
      return Text(
        note,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
      );
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        children: [
          TextSpan(text: '${parts[0]}:'),
          TextSpan(
            text: parts.sublist(1).join(':'),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Action button

class _ActionButton extends StatelessWidget {
  final String label;
  final bool canCancel;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.canCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (canCancel) {
      // Red outlined cancel button
      return SizedBox(
        height: 38,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(color: Color(0xFFDC2626)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Teal outlined button (View Details / View Receipt)
    if (label == 'View Receipt') {
      return GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1B6B61),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF1B6B61),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1B6B61),
          side: const BorderSide(color: Color(0xFF1B6B61)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
