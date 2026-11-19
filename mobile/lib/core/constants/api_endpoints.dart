import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Base URL default dinamis sesuai platform
  static String _customBaseUrl = '';

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    // Jika berjalan di Web atau Desktop Windows/macOS/Linux:
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:5000/api/v1';
    }

    // Jika di Android/iOS Fisik / LAN:
    return 'http://192.168.0.102:5000/api/v1';
  }

  /// Mengatur custom server host jika berpindah jaringan Wi-Fi
  static void setBaseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  // Fallback emulator jika diperlukan
  static const String emulatorBaseUrl = 'http://10.0.2.2:5000/api/v1';

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get registerCustomer => '$baseUrl/auth/register-customer';
  static String get me => '$baseUrl/auth/me';
  static String get profile => '$baseUrl/auth/profile';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';

  // Users Management Endpoints (Admin / Owner only)
  static String get users => '$baseUrl/users';
  static String userStatus(int id) => '$baseUrl/users/$id/status';
  static String userDetail(int id) => '$baseUrl/users/$id';

  // Product & Category Endpoints
  static String get products => '$baseUrl/products';
  static String productDetail(int id) => '$baseUrl/products/$id';
  static String productBarcode(String code) => '$baseUrl/products/barcode/$code';
  static String get categories => '$baseUrl/categories';
  static String categoryDetail(int id) => '$baseUrl/categories/$id';

  // Dashboard Endpoints (Admin / Owner only)
  static String get dashboard => '$baseUrl/dashboard';
  static String get salesChart => '$baseUrl/dashboard/sales-chart';
  static String get transactionStats => '$baseUrl/dashboard/transaction-stats';
  static String get bestSelling => '$baseUrl/dashboard/best-selling';
  static String get financialReport => '$baseUrl/dashboard/financial-report';

  // Sales / POS Endpoints (Kasir & Owner)
  static String get sales => '$baseUrl/sales';
  static String saleDetail(int id) => '$baseUrl/sales/$id';
  static String voidSale(int id) => '$baseUrl/sales/$id/void';

  // Expenses Endpoints (Owner only)
  static String get expenses => '$baseUrl/expenses';
  static String get expenseCategories => '$baseUrl/expenses/categories';
  static String expenseDetail(int id) => '$baseUrl/expenses/$id';

  // Customers Endpoints
  static String get customers => '$baseUrl/customers';
  static String customerDetail(int id) => '$baseUrl/customers/$id';

  // Suppliers Endpoints
  static String get suppliers => '$baseUrl/suppliers';
  static String supplierDetail(int id) => '$baseUrl/suppliers/$id';

  // Notification Endpoints
  static String get notifications => '$baseUrl/notifications';
  static String readNotification(int id) => '$baseUrl/notifications/$id/read';

  // Order Endpoints (Pengunjung / Pembeli, Kasir, Admin)
  static String get orders => '$baseUrl/orders';
  static String orderDetail(int id) => '$baseUrl/orders/$id';
  static String orderStatus(int id) => '$baseUrl/orders/$id/status';

  // Health
  static String get health => '$baseUrl/health';
}
