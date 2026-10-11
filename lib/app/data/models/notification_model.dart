class NotificationModel {
  final int id;
  final String? type;
  final String? title;
  final String? message;
  final String? createdAt;
  final bool? isRead;
  final Map<String, dynamic>? extraData;

  const NotificationModel({
    required this.id,
    this.type,
    this.title,
    this.message,
    this.createdAt,
    this.isRead,
    this.extraData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final extra = json['extra_data'];
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['action'] as String? ?? json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String? ?? json['notify_text'] as String?,
      createdAt: json['created_at']?.toString(),
      isRead: json['is_read'] as bool? ?? false,
      extraData: extra is Map ? Map<String, dynamic>.from(extra) : null,
    );
  }
}
