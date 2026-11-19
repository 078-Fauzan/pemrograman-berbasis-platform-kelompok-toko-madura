class SalesChartPoint {
  final String date;
  final String formattedDate;
  final double totalAmount;
  final int transactionCount;

  SalesChartPoint({
    required this.date,
    required this.formattedDate,
    required this.totalAmount,
    required this.transactionCount,
  });

  factory SalesChartPoint.fromJson(Map<String, dynamic> json) {
    return SalesChartPoint(
      date: json['date'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : 0.0,
      transactionCount: json['transaction_count'] != null
          ? int.tryParse(json['transaction_count'].toString()) ?? 0
          : 0,
    );
  }
}
