class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String? barcode;
  final String? unit;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.barcode,
    this.unit,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 1,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      subtotal: json['subtotal'] != null
          ? double.tryParse(json['subtotal'].toString()) ?? 0.0
          : 0.0,
      barcode: json['barcode'],
      unit: json['unit'],
    );
  }
}

class OrderModel {
  final int id;
  final int storeId;
  final int userId;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final String orderType; // 'takeaway' atau 'delivery'
  final String? deliveryAddress;
  final String paymentMethod; // 'cash', 'qris', 'transfer'
  final String status; // 'pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled'
  final String? notes;
  final String? createdAt;
  final int totalItems;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.orderType,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.createdAt,
    this.totalItems = 0,
    this.items,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isReady => status == 'ready';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'processing':
        return 'Sedang Disiapkan';
      case 'ready':
        return orderType == 'delivery' ? 'Siap Diantar' : 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel>? itemsList;
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.parse(json['store_id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      orderNumber: json['order_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : 0.0,
      orderType: json['order_type'] ?? 'takeaway',
      deliveryAddress: json['delivery_address'],
      paymentMethod: json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'],
      totalItems: json['total_items'] != null
          ? int.tryParse(json['total_items'].toString()) ?? 0
          : (itemsList?.length ?? 0),
      items: itemsList,
    );
  }
}
