import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/profile/presentation/page/our_story_page.dart';
import 'package:yarn_craft_nepal/features/profile/presentation/page/contact_page.dart';

import '../../../../features/auth/presentation/page/welcome_page.dart';
import '../../../../features/auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../../features/catalog/presentation/page/cart_page.dart';
import '../../../../features/catalog/presentation/page/saved_item.dart';
import '../../../../features/product/presentation/page/order_history.dart';

import '../../../../features/admin/presentation/page/admin_dashboard_page.dart';
import 'edit_profile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final name = user?.name ?? 'Guest User';
    final email = user?.email ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'G';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Center(
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Avatar
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFE8F5F3),
                      child: user?.imageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user!.imageUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Color(0xFF1B6B61),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              initials,
                              style: const TextStyle(
                                color: Color(0xFF1B6B61),
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),

                    const SizedBox(height: 28),

                    // My Activity section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Text(
                              'My Activity',
                              style: TextStyle(
                                color: Color(0xFF1B6B61),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          const Divider(color: Color(0xFFE5E7EB), height: 1),

                          _MenuItem(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Cart',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.favorite_border,
                            label: 'Liked',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SavedItemsPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Order History',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderHistoryPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.person_outline,
                            label: 'Edit Profile',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            ),
                          ),
                          if (user?.isAdmin == true)
                            _MenuItem(
                              icon: Icons.admin_panel_settings_outlined,
                              label: 'Admin Panel',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardPage(),
                                ),
                              ),
                            ),
                          _MenuItem(
                            icon: Icons.help_outline,
                            label: 'Help & Support',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ContactHelpPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.info_outline,
                            label: 'About',
                            trailing: const Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OurStoryPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Log Out
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(
                            color: Color(0xFFDC2626),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (_) => false,
                );
              }
            },
            child: const Text(
              'Log Out',
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
}

// Menu item

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF6B7280), size: 20),
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
      const Divider(
        color: Color(0xFFE5E7EB),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
    ],
  );
}
