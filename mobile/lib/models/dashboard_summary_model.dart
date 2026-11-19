class DashboardSummaryModel {
  final double salesToday;
  final int transactionsToday;
  final int totalProducts;
  final int lowStockProducts;
  final double expensesToday;

  DashboardSummaryModel({
    required this.salesToday,
    required this.transactionsToday,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.expensesToday,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      salesToday: json['sales_today'] != null
          ? double.tryParse(json['sales_today'].toString()) ?? 0.0
          : 0.0,
      transactionsToday: json['transactions_today'] != null
          ? int.tryParse(json['transactions_today'].toString()) ?? 0
          : 0,
      totalProducts: json['total_products'] != null
          ? int.tryParse(json['total_products'].toString()) ?? 0
          : 0,
      lowStockProducts: json['low_stock_products'] != null
          ? int.tryParse(json['low_stock_products'].toString()) ?? 0
          : 0,
      expensesToday: json['expenses_today'] != null
          ? double.tryParse(json['expenses_today'].toString()) ?? 0.0
          : 0.0,
    );
  }

  factory DashboardSummaryModel.empty() {
    return DashboardSummaryModel(
      salesToday: 0.0,
      transactionsToday: 0,
      totalProducts: 0,
      lowStockProducts: 0,
      expensesToday: 0.0,
    );
  }
}
