import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/service/api_url.dart';
import 'package:working_hiring/app/data/models/notification_model.dart';
export 'package:working_hiring/app/data/models/notification_model.dart';

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

  Future<NotificationModel> getNotification(int id) async {
    final response = await _client.get(
      url: _fullUrl(ApiUrl.notificationDetail(id)),
    );
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
