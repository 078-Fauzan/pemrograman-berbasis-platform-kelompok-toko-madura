import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        } else if (constraints.maxWidth >= 700) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

class NavigationItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;

  const NavigationItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

class AdaptiveScaffoldShell extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigationIndexChanged;
  final List<NavigationItemData> items;
  final List<Widget> pages;
  final Widget? headerAction;
  final String appTitle;
  final String userRoleText;
  final String userName;
  final VoidCallback onLogout;

  const AdaptiveScaffoldShell({
    super.key,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.items,
    required this.pages,
    this.headerAction,
    this.appTitle = 'UMKMate • Toko Madura',
    required this.userRoleText,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveLayout.isMobile(context);
    final safeIndex = currentIndex < pages.length ? currentIndex : 0;

    if (!isWide) {
      // Mobile Layout: BottomNavigationBar
      return Scaffold(
        body: IndexedStack(
          index: safeIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: onNavigationIndexChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor: Colors.white,
          elevation: 8,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: items.map((item) {
            Widget iconWidget = Icon(item.icon);
            Widget activeIconWidget = Icon(item.activeIcon);

            if (item.badgeCount != null && item.badgeCount! > 0) {
              iconWidget = Badge(
                label: Text('${item.badgeCount}'),
                child: iconWidget,
              );
              activeIconWidget = Badge(
                label: Text('${item.badgeCount}'),
                child: activeIconWidget,
              );
            }

            return BottomNavigationBarItem(
              icon: iconWidget,
              activeIcon: activeIconWidget,
              label: item.label,
            );
          }).toList(),
        ),
      );
    }

    // Desktop & Web Layout: Sidebar Navigation + Top Header + Body
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                userRoleText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = safeIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Material(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => onNavigationIndexChanged(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (item.badgeCount != null && item.badgeCount! > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // User Info & Logout Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                        tooltip: 'Keluar',
                        onPressed: onLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Body (Content Area)
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
