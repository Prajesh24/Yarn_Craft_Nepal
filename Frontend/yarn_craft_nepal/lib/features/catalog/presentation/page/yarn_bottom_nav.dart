import 'package:flutter/material.dart';

enum NavTab { home, search, cart, profile }

class YarnBottomNav extends StatelessWidget {
  final NavTab current;
  final ValueChanged<NavTab> onTap;

  const YarnBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
              _NavItem(
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart,
                label: 'Cart',
                tab: NavTab.cart,
                current: current,
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
