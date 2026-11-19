import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingOrdersCount =>
      _orders.where((o) => o.status == 'pending').length;

  /// Ambil daftar pesanan (Sesuai role aktif dari token: Customer hanya miliknya, Admin/Kasir seluruh toko)
  Future<void> fetchOrders({String? status, String? orderType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String url = ApiEndpoints.orders;
    final params = <String>[];
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (orderType != null && orderType.isNotEmpty) params.add('order_type=$orderType');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await ApiService.get(url);
    _isLoading = false;

    if (response.success && response.data != null) {
      final List dataList = response.data is List ? response.data : [];
      _orders = dataList.map((item) => OrderModel.fromJson(item)).toList();
      notifyListeners();
    } else {
      _errorMessage = response.message;
      notifyListeners();
    }
  }

  /// Ambil detail rincian 1 pesanan
  Future<OrderModel?> fetchOrderDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get(ApiEndpoints.orderDetail(id));
    _isLoading = false;

    if (response.success && response.data != null) {
      _selectedOrder = OrderModel.fromJson(response.data);
      notifyListeners();
      return _selectedOrder;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  /// Buat pesanan baru (Oleh Pembeli atau Kasir)
  Future<bool> createOrder({
    required String orderType,
    String? deliveryAddress,
    String paymentMethod = 'cash',
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post(
      ApiEndpoints.orders,
      body: {
        'order_type': orderType,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'notes': notes,
        'items': items,
      },
    );

    _isLoading = false;

    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Update status pesanan (Admin / Kasir)
  Future<bool> updateOrderStatus(int id, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.patch(
      ApiEndpoints.orderStatus(id),
      body: {'status': newStatus},
    );

    _isLoading = false;

    if (response.success) {
      // Perbarui status lokal pada daftar pesanan
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        final old = _orders[index];
        _orders[index] = OrderModel(
          id: old.id,
          storeId: old.storeId,
          userId: old.userId,
          orderNumber: old.orderNumber,
          customerName: old.customerName,
          customerPhone: old.customerPhone,
          totalAmount: old.totalAmount,
          orderType: old.orderType,
          deliveryAddress: old.deliveryAddress,
          paymentMethod: old.paymentMethod,
          status: newStatus,
          notes: old.notes,
          createdAt: old.createdAt,
          totalItems: old.totalItems,
          items: old.items,
        );
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
}
