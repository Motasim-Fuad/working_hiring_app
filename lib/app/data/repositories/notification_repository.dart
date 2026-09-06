import '../../service/api_service.dart';
import '../../service/api_url.dart';

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

class NotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get(url: _fullUrl(ApiUrl.notifications));
    final data = parseApiResponse(response);
    final list = data is List
        ? data
        : (data is Map && data['results'] is List)
            ? data['results'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .where((n) => n.id > 0)
        .toList();
  }

  // GET /notifications/{id}/ auto-marks the notification as read (no POST /read/ endpoint exists).
  Future<NotificationModel> getNotification(int id) async {
    final response = await _client.get(url: _fullUrl(ApiUrl.notificationDetail(id)));
    final data = parseApiResponse(response);
    return NotificationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> markRead(int id) => getNotification(id).then((_) {});

  Future<void> markAllRead() async {
    await _client.patch(
      url: _fullUrl(ApiUrl.notifications),
      body: {'is_read': true},
    );
  }

  Future<void> deleteNotification(int id) async {
    await _client.delete(url: '${_fullUrl(ApiUrl.notifications)}$id/');
  }
}
