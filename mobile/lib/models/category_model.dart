class CategoryModel {
  final int id;
  final int storeId;
  final String categoryName;
  final int totalProducts;

  CategoryModel({
    required this.id,
    required this.storeId,
    required this.categoryName,
    this.totalProducts = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.parse(json['store_id'].toString()),
      categoryName: json['category_name'] ?? '',
      totalProducts: json['total_products'] != null
          ? int.tryParse(json['total_products'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_name': categoryName,
      'total_products': totalProducts,
    };
  }
}
