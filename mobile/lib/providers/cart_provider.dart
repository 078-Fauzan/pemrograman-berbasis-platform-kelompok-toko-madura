import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItemModel> _items = {};

  // Khusus Kasir POS
  double _discount = 0.0;
  double _cashReceived = 0.0;
  String _paymentMethod = 'cash'; // 'cash', 'qris', 'transfer'
  bool _isSubmitting = false;
  String? _lastInvoiceNumber;
  String? _errorMessage;

  Map<int, CartItemModel> get items => {..._items};
  List<CartItemModel> get itemsList => _items.values.toList();
  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get discount => _discount;
  double get cashReceived => _cashReceived;
  String get paymentMethod => _paymentMethod;
  bool get isSubmitting => _isSubmitting;
  String? get lastInvoiceNumber => _lastInvoiceNumber;
  String? get errorMessage => _errorMessage;

  double get finalTotal {
    final total = subtotal - _discount;
    return total > 0 ? total : 0.0;
  }

  double get changeAmount {
    if (_cashReceived <= 0) return 0.0;
    final change = _cashReceived - finalTotal;
    return change > 0 ? change : 0.0;
  }

  bool get isPaymentSufficient {
    if (_paymentMethod != 'cash') return true;
    return _cashReceived >= finalTotal;
  }

  bool get isEmpty => _items.isEmpty;

  /// Tambah produk ke keranjang
  void addItem(ProductModel product, [int quantity = 1]) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// Kurangi kuantitas atau hapus jika 1
  void decrementItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Tambah 1 kuantitas
  void incrementItem(int productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  /// Update kuantitas langsung
  void updateQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId]!.quantity = quantity;
    }
    notifyListeners();
  }

  /// Hapus 1 produk dari keranjang
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Kosongkan keranjang
  void clearCart() {
    _items.clear();
    _discount = 0.0;
    _cashReceived = 0.0;
    _paymentMethod = 'cash';
    notifyListeners();
  }

  // Setters untuk Kasir POS
  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setCashReceived(double amount) {
    _cashReceived = amount;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Eksekusi checkout transaksi POS ke server backend
  Future<Map<String, dynamic>?> submitSale({int? customerId}) async {
    if (isEmpty) return null;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'customer_id': customerId,
        'discount': _discount,
        'items': itemsList
            .map((item) => {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                })
            .toList(),
        'payment': {
          'payment_method': _paymentMethod,
          'amount': finalTotal,
          'cash_received': _paymentMethod == 'cash' ? _cashReceived : finalTotal,
          'change_amount': changeAmount,
        },
      };

      final response = await ApiService.post(ApiEndpoints.sales, body: payload);
      _isSubmitting = false;

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _lastInvoiceNumber = data['invoice_number']?.toString();
        notifyListeners();
        return data;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Terjadi kesalahan saat memproses transaksi: $e';
      notifyListeners();
      return null;
    }
  }
}
