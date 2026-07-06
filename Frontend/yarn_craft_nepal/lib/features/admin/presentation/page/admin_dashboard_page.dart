import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entity/product_entity.dart';
import '../../../catalog/presentation/viewmodel/product_viewmodel.dart';
import '../viewmodel/admin_product_viewmodel.dart';
import 'admin_product_form_page.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'Admin — Products',
          style: TextStyle(
            color: Color(0xFF1B6B61),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1B6B61)),
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B6B61),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Product',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminProductFormPage(),
            ),
          );
          if (added == true) ref.invalidate(productsProvider);
        },
      ),
      body: productsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF1B6B61))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load products: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) => products.isEmpty
            ? const Center(
                child: Text('No products yet. Tap + to create one.',
                    style: TextStyle(color: Color(0xFF6B7280))))
            : ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemCount: products.length,
                itemBuilder: (ctx, i) => _ProductAdminCard(
                  product: products[i],
                  onEdit: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminProductFormPage(product: products[i]),
                      ),
                    );
                    if (updated == true) ref.invalidate(productsProvider);
                  },
                  onDelete: () =>
                      _confirmDelete(context, ref, products[i]),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final ok =
        await ref.read(adminProductProvider.notifier).deleteProduct(product.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content:
            Text(ok ? '${product.name} deleted.' : 'Failed to delete product.'),
        backgroundColor: ok ? const Color(0xFF1B6B61) : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }
}

class _ProductAdminCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
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
            width: 60,
            height: 60,
            color: const Color(0xFFE8F5F3),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.texture,
                      color: Color(0xFF1B6B61),
                      size: 24,
                    ),
                  )
                : const Icon(Icons.texture,
                    color: Color(0xFF1B6B61), size: 24),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  color: Color(0xFF1B6B61),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.category,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionBtn(
              icon: Icons.edit_outlined,
              color: const Color(0xFF1B6B61),
              onTap: onEdit,
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              icon: Icons.delete_outline,
              color: const Color(0xFFDC2626),
              onTap: onDelete,
            ),
          ],
        ),
      ],
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}
