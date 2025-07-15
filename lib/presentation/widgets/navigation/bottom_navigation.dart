import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum NavigationTab { freeScan, packs, decks, stats }

class CustomBottomNavigation extends StatelessWidget {
  final NavigationTab currentTab;
  final Function(NavigationTab) onTabSelected;

  const CustomBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: NavigationTab.freeScan,
                icon: Icons.camera_alt_outlined,
                activeIcon: Icons.camera_alt,
                label: 'Free Scan',
              ),
              _buildNavItem(
                tab: NavigationTab.packs,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Sobres',
              ),
              _buildNavItem(
                tab: NavigationTab.decks,
                icon: Icons.style_outlined,
                activeIcon: Icons.style,
                label: 'Decks',
              ),
              _buildNavItem(
                tab: NavigationTab.stats,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavigationTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
