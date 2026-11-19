class ProductModel {
  final int id;
  final int storeId;
  final int? categoryId;
  final String? categoryName;
  final String productName;
  final String? barcode;
  final String unit;
  final double? costPrice; // Nullable jika diakses kasir (disembunyikan oleh backend)
  final double sellingPrice;
  final int stock;
  final int minimumStock;
  final bool isActive;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId,
    this.categoryName,
    required this.productName,
    this.barcode,
    required this.unit,
    this.costPrice,
    required this.sellingPrice,
    required this.stock,
    required this.minimumStock,
    required this.isActive,
    this.updatedAt,
  });

  bool get isLowStock => stock <= minimumStock;
  bool get isOutOfStock => stock <= 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.parse(json['store_id'].toString()),
      categoryId: json['category_id'] != null
          ? int.tryParse(json['category_id'].toString())
          : null,
      categoryName: json['category_name'],
      productName: json['product_name'] ?? '',
      barcode: json['barcode'],
      unit: json['unit'] ?? 'Pcs',
      costPrice: json['cost_price'] != null
          ? double.tryParse(json['cost_price'].toString())
          : null,
      sellingPrice: json['selling_price'] != null
          ? double.tryParse(json['selling_price'].toString()) ?? 0.0
          : 0.0,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
      minimumStock: json['minimum_stock'] != null
          ? int.tryParse(json['minimum_stock'].toString()) ?? 5
          : 5,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'product_name': productName,
      'barcode': barcode,
      'unit': unit,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'minimum_stock': minimumStock,
      'is_active': isActive ? 1 : 0,
    };
  }
}
