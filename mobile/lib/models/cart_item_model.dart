import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.sellingPrice * quantity;

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  Map<String, dynamic> toOrderItemJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
    };
  }
}
