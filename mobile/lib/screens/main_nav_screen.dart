import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/responsive_layout.dart';
import 'auth/login_screen.dart';
import 'dashboard/owner_dashboard_tab.dart';
import 'dashboard/cashier_dashboard_tab.dart';
import 'products/product_list_tab.dart';
import 'profile/profile_tab.dart';
import 'pos/cashier_pos_screen.dart';
import 'orders/store_orders_tab.dart';
import 'customer/customer_home_tab.dart';
import 'customer/customer_cart_tab.dart';
import 'customer/customer_orders_tab.dart';
import 'customer/customer_profile_tab.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleLogout() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    await auth.logout();
    cart.clearCart();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final orderProv = context.watch<OrderProvider>();

    final user = auth.user;
    final isCustomer = auth.isCustomer;
    final isCashier = auth.isCashier;

    List<Widget> pages = [];
    List<NavigationItemData> navItems = [];

    if (isCustomer) {
      // 1. ROLE 3: PENGUNJUNG / PEMBELI
      pages = [
        CustomerHomeTab(onNavigateToCart: () => _onTabSelected(1)),
        CustomerCartTab(
          onNavigateToOrders: () => _onTabSelected(2),
          onNavigateToShop: () => _onTabSelected(0),
        ),
        const CustomerOrdersTab(),
        const CustomerProfileTab(),
      ];

      navItems = [
        const NavigationItemData(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: 'Etalase',
        ),
        NavigationItemData(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag,
          label: 'Keranjang',
          badgeCount: cart.totalQuantity > 0 ? cart.totalQuantity : null,
        ),
        const NavigationItemData(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Pesanan Saya',
        ),
        const NavigationItemData(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
        ),
      ];
    } else if (isCashier) {
      // 2. ROLE 2: KASIR
      pages = [
        const CashierPosScreen(),
        const StoreOrdersTab(),
        const ProductListTab(),
        CashierDashboardTab(
          onNavigateToProducts: () => _onTabSelected(2),
          onNavigateToPos: () => _onTabSelected(0),
        ),
        const ProfileTab(),
      ];

      navItems = [
        NavigationItemData(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Kasir POS',
          badgeCount: cart.totalQuantity > 0 ? cart.totalQuantity : null,
        ),
        NavigationItemData(
          icon: Icons.inbox_outlined,
          activeIcon: Icons.inbox,
          label: 'Pesanan Masuk',
          badgeCount: orderProv.pendingOrdersCount > 0
              ? orderProv.pendingOrdersCount
              : null,
        ),
        const NavigationItemData(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Katalog',
        ),
        const NavigationItemData(
          icon: Icons.query_builder,
          activeIcon: Icons.query_builder,
          label: 'Shift Kasir',
        ),
        const NavigationItemData(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Akun',
        ),
      ];
    } else {
      // 3. ROLE 1: ADMIN (Owner / Administrator)
      pages = [
        OwnerDashboardTab(
          onNavigateToProducts: () => _onTabSelected(1),
          onNavigateToPos: () => _onTabSelected(2),
        ),
        const ProductListTab(),
        const CashierPosScreen(),
        const StoreOrdersTab(),
        const ProfileTab(),
      ];

      navItems = [
        const NavigationItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        const NavigationItemData(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Master Produk',
        ),
        NavigationItemData(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Kasir POS',
          badgeCount: cart.totalQuantity > 0 ? cart.totalQuantity : null,
        ),
        NavigationItemData(
          icon: Icons.shopping_basket_outlined,
          activeIcon: Icons.shopping_basket,
          label: 'Pesanan Toko',
          badgeCount: orderProv.pendingOrdersCount > 0
              ? orderProv.pendingOrdersCount
              : null,
        ),
        const NavigationItemData(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Pengaturan',
        ),
      ];
    }

    // Pastikan _currentIndex tidak melebihi range jika role berubah
    final safeIndex = _currentIndex < pages.length ? _currentIndex : 0;

    return AdaptiveScaffoldShell(
      currentIndex: safeIndex,
      onNavigationIndexChanged: _onTabSelected,
      items: navItems,
      pages: pages,
      appTitle: 'Toko Madura • UMKMate',
      userRoleText: user?.roleDisplayName ?? 'Pengguna',
      userName: user?.name ?? 'Pengguna',
      onLogout: _handleLogout,
    );
  }
}
