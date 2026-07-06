import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/catalog/presentation/page/cart_page.dart';
import '../features/catalog/presentation/page/home_page.dart';
import '../features/product/presentation/page/product_listing.dart';
import '../features/catalog/presentation/page/yarn_bottom_nav.dart';
import '../features/catalog/presentation/viewmodel/cart_viewmodel.dart';
import '../features/catalog/presentation/viewmodel/tab_viewmodel.dart';
import '../features/profile/presentation/page/profile_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Restore the signed-in user's saved cart from the backend so it survives
    // app restarts / reloads (the local cart state is otherwise empty on boot).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).loadFromBackend();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final cartCount = ref.watch(cartProvider).totalItems;

    return Scaffold(
      body: IndexedStack(
        index: currentTab.index,
        children: const [
          HomePage(),
          ProductListingPage(),
          CartPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _BottomNavWithBadge(
        current: currentTab,
        cartCount: cartCount,
        onTap: (tab) => ref.read(currentTabProvider.notifier).switchTo(tab),
      ),
    );
  }
}

class _BottomNavWithBadge extends StatelessWidget {
  final NavTab current;
  final int cartCount;
  final ValueChanged<NavTab> onTap;

  const _BottomNavWithBadge({
    required this.current,
    required this.cartCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                tab: NavTab.home,
                current: current,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Search',
                tab: NavTab.search,
                current: current,
                onTap: onTap,
              ),
              _CartNavItem(
                tab: NavTab.cart,
                current: current,
                cartCount: cartCount,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                tab: NavTab.profile,
                current: current,
                onTap: onTap,
                useCircleBg: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final NavTab tab, current;
  final ValueChanged<NavTab> onTap;
  final bool useCircleBg;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tab,
    required this.current,
    required this.onTap,
    this.useCircleBg = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == current;
    final color = isActive ? const Color(0xFF1B6B61) : const Color(0xFF9CA3AF);

    Widget iconWidget = Icon(
      isActive ? activeIcon : icon,
      color: color,
      size: 22,
    );

    if (useCircleBg && isActive) {
      iconWidget = Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5F3),
          shape: BoxShape.circle,
        ),
        child: Icon(activeIcon, color: const Color(0xFF1B6B61), size: 20),
      );
    }

    return GestureDetector(
      onTap: () => onTap(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final NavTab tab, current;
  final int cartCount;
  final ValueChanged<NavTab> onTap;

  const _CartNavItem({
    required this.tab,
    required this.current,
    required this.cartCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == current;
    final color = isActive ? const Color(0xFF1B6B61) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: () => onTap(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                color: color,
                size: 22,
              ),
              if (cartCount > 0)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B6B61),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartCount > 9 ? '9+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Cart',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
