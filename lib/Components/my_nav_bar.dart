import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final List<int>? badgeCounts;

  const MyNavBar({
    required this.selectedIndex,
    required this.onTabChange,
    this.badgeCounts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GNav(
        gap: 6,
        haptic: true,
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        tabBorderRadius: 16,
        tabActiveBorder: Border.all(color: scheme.primary, width: 1),
        tabBackgroundColor: scheme.primary,
        iconSize: 24,
        backgroundColor: Colors.transparent,
        color: scheme.onSurface.withOpacity(0.7),
        activeColor: scheme.onPrimary,
        tabMargin: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [
          _buildTab(
            icon: Icons.add_box_outlined,
            text: 'Add',
            badgeCount: badgeCounts?[0],
            tooltip: 'Create new item',
            scheme: scheme,
          ),
          _buildTab(
            icon: Icons.home,
            text: 'Home',
            badgeCount: badgeCounts?[1],
            tooltip: 'Go home',
            scheme: scheme,
          ),
          _buildTab(
            icon: Icons.settings,
            text: 'Settings',
            badgeCount: badgeCounts?[2],
            tooltip: 'App settings',
            scheme: scheme,
          ),
        ],
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
      ),
    );
  }

  GButton _buildTab({
    required IconData icon,
    required String text,
    int? badgeCount,
    required String tooltip,
    required ColorScheme scheme,
  }) {
    return GButton(
      icon: icon,
      text: text,
      leading: badgeCount != null && badgeCount > 0
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24),
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badgeCount.toString(),
                      style: TextStyle(
                        color: scheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : null,
      textStyle: TextStyle(
        color: scheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
