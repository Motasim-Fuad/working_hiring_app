import 'package:working_hiring/app/data/utils/json_parsers.dart';
import 'package:flutter/foundation.dart';

import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/service/api_url.dart';
import 'package:working_hiring/app/data/models/chat_message_model.dart';
import 'package:working_hiring/app/data/models/chat_room_model.dart';
export 'package:working_hiring/app/data/models/chat_message_model.dart';
export 'package:working_hiring/app/data/models/chat_room_model.dart';

class ChatRepository {
  final ApiClient _client;

  ChatRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  Future<ChatRoomModel> startChat(int providerId) async {
    _client.profileType = 'customer';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.startChat),
      body: {'provider_id': providerId},
    );
    final body = response.body;
    debugPrint(
      '[ROOM] startChat raw body keys: ${body is Map ? body.keys.toList() : body}',
    );
    if (body is Map && body['status'] == true) {
      final roomData = (body['room'] ?? body['data']) as Map<String, dynamic>?;
      debugPrint(
        '[ROOM] startChat roomData keys: ${roomData?.keys.toList()} id=${roomData?['id']} uuid=${roomData?['uuid']}',
      );
      if (roomData == null) {
        throw ApiException('Chat room not returned by server', body);
      }
      return ChatRoomModel.fromJson(roomData, isProviderView: false);
    }
    final msg = body is Map
        ? (body['message'] is String
              ? body['message'] as String
              : 'Failed to start chat')
        : 'Failed to start chat';
    throw ApiException(msg, body);
  }

  Future<List<ChatRoomModel>> getCustomerRooms() async {
    _client.profileType = 'customer';
    final response = await _client.get(url: _fullUrl(ApiUrl.customerRooms));
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    debugPrint('[ROOM] customerRooms count=${list.length}');
    if (list.isNotEmpty) {
      final first = list.first as Map;
      debugPrint('[ROOM] first room ALL keys: ${first.keys.toList()}');
      debugPrint(
        '[ROOM] first room id="${first['id']}" uuid="${first['uuid']}" room_id="${first['room_id']}"',
      );
    }
    final rooms = list
        .map(
          (e) => ChatRoomModel.fromJson(
            e as Map<String, dynamic>,
            isProviderView: false,
          ),
        )
        .toList();

    return Future.wait(
      rooms.map((room) async {
        if (room.name != null) return room;
        final company = await _resolveRoomCompany(room.uuid);
        return room.copyWith(
          name: company?.name ?? 'Helper',
          photo: company?.logo,
        );
      }),
    );
  }

  final Map<String, ({String? name, String? logo})> _roomCompanyCache = {};

  /// Seeds the company for a freshly started room, which has no order in its
  /// history yet and therefore cannot be resolved from the server.
  void rememberRoomCompany(String uuid, {required String name, String? logo}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _roomCompanyCache[uuid] = (name: trimmed, logo: nonEmptyString(logo));
  }

  final Map<int, ({String? name, String? logo})> _orderCompanyCache = {};

  /// The customer room list only exposes the provider's personal name, so the
  /// company is looked up through an order referenced in the room's history.
  Future<({String? name, String? logo})?> _resolveRoomCompany(
    String uuid,
  ) async {
    final cached = _roomCompanyCache[uuid];
    if (cached != null) return cached;
    try {
      final messages = await getMessagesByUuid(uuid, profileType: 'customer');
      final orderId = messages
          .map((m) => m.eventData?['id'])
          .whereType<int>()
          .firstOrNull;
      if (orderId == null) return null;

      var company = _orderCompanyCache[orderId];
      if (company == null) {
        _client.profileType = 'customer';
        final response = await _client.get(
          url: _fullUrl(ApiUrl.customerOrderDetail(orderId)),
        );
        final data = parseApiResponse(response);
        final provider = data is Map ? data['provider'] : null;
        if (provider is! Map) return null;
        company = (
          name: nonEmptyString(provider['company_name']),
          logo:
              nonEmptyString(provider['logo']) ??
              nonEmptyString(provider['photo']),
        );
        _orderCompanyCache[orderId] = company;
      }
      if (company.name != null) _roomCompanyCache[uuid] = company;
      return company;
    } catch (e) {
      debugPrint('[ROOM] resolve company failed for $uuid: $e');
      return null;
    }
  }

  Future<List<ChatRoomModel>> getProviderRooms() async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerRooms));
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    debugPrint('[ROOM] providerRooms count=${list.length}');
    if (list.isNotEmpty) {
      final first = list.first as Map;
      debugPrint('[ROOM] first provider room ALL keys: ${first.keys.toList()}');
      debugPrint(
        '[ROOM] first provider room id="${first['id']}" uuid="${first['uuid']}" room_id="${first['room_id']}"',
      );
    }
    return list
        .map(
          (e) => ChatRoomModel.fromJson(
            e as Map<String, dynamic>,
            isProviderView: true,
          ),
        )
        .toList();
  }

  Future<List<ChatMessageModel>> getMessagesByUuid(
    String uuid, {
    required String profileType,
  }) async {
    _client.profileType = profileType;
    final response = await _client.get(
      url: _fullUrl('${ApiUrl.roomMessagesByUuid(profileType)}?uuid=$uuid'),
    );
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches paginated message history for [roomPk] (integer ChatRoom id).
  Future<List<ChatMessageModel>> getMessages(
    int roomPk, {
    String profileType = 'customer',
  }) async {
    _client.profileType = profileType;
    final response = await _client.get(
      url: _fullUrl(ApiUrl.roomMessages(roomPk)),
    );
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
