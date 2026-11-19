class NotificationModel {
  final int id;
  final int storeId;
  final int? userId;
  final String title;
  final String message;
  final String type; // 'stock_alert', 'system', 'transaction'
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.storeId,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.parse(json['store_id'].toString()),
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}
