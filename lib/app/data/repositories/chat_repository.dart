import 'package:flutter/foundation.dart';

import '../../service/api_service.dart';
import '../../service/api_url.dart';

/// Backend sends `attachments` as a LIST (e.g. [{file_url, name, mime, size}]).
/// Some older frames send a single Map. Normalize to the first attachment map.
Map<String, dynamic>? _firstAttachment(dynamic attachments) {
  if (attachments is List && attachments.isNotEmpty) {
    final first = attachments.first;
    return first is Map<String, dynamic> ? first : null;
  }
  if (attachments is Map<String, dynamic> && attachments.isNotEmpty) {
    return attachments;
  }
  return null;
}

class ChatRoomModel {
  /// Integer primary key — used for GET /room/{id}/message/.
  /// Nullable because some backend responses (e.g. /room/start-chat/) only
  /// return the uuid.
  final int? id;

  /// UUID — used for WebSocket connection
  final String uuid;
  final String? name;
  final String? photo;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool? isOnline;
  final int? unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.uuid,
    this.name,
    this.photo,
    this.lastMessage,
    this.lastMessageTime,
    this.isOnline,
    this.unreadCount,
  });

  /// [isProviderView] — true when the current user is the provider, so the
  /// "other" user in the room is the customer.  False means we are the
  /// customer and the other user is the provider.
  factory ChatRoomModel.fromJson(
    Map<String, dynamic> json, {
    required bool isProviderView,
  }) {
    String? name;
    String? photo;

    // Preferred (and observed) shape: backend returns an `other_user` object
    // regardless of role.
    final otherUser = json['other_user'] as Map<String, dynamic>?;
    if (otherUser != null) {
      final firstName = (otherUser['first_name'] as String?) ?? '';
      final lastName = (otherUser['last_name'] as String?) ?? '';
      final full = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      name = full.isNotEmpty ? full : null;
      photo = otherUser['photo'] as String?;
    } else if (isProviderView) {
      // Fallback to the documented split shape.
      final customer = json['customer'] as Map<String, dynamic>?;
      final firstName = (customer?['first_name'] as String?) ?? '';
      final lastName = (customer?['last_name'] as String?) ?? '';
      final full = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      name = full.isNotEmpty ? full : null;
      photo = customer?['photo'] as String?;
    } else {
      final provider = json['provider'] as Map<String, dynamic>?;
      name = provider?['company_name'] as String?;
      photo = provider?['logo'] as String?;
    }

    final lastMessageObj = json['last_message'] as Map<String, dynamic>?;
    final lastMessageContent = lastMessageObj?['content'] as String?;
    final lastMessageTimestamp = lastMessageObj?['timestamp']?.toString();

    return ChatRoomModel(
      // id: json['id'] as int?,
      id: json['room_id'] as int? ?? json['id'] as int?,
      uuid: json['uuid'] as String,
      name: name,
      photo: photo,
      lastMessage: lastMessageContent,
      lastMessageTime: lastMessageTimestamp,
      isOnline: null,
      unreadCount: json['unread_count'] as int?,
    );
  }
}

class ChatMessageModel {
  final int? id;
  final String? text;
  final String? senderName;
  final String? senderPhoto;
  final bool? isMe;
  final String? createdAt;
  final String? type;
  final Map<String, dynamic>? extraData;
  // "CUSTOMER" or "PROVIDER"
  final String? senderRole;
  // "TEXT" / "EVENT" / "IMAGE" / "VIDEO" / "AUDIO" / "FILE"
  final String? messageType;
  // event.event_type — non-null only for EVENT messages
  final String? eventType;
  // event.order_object (raw map, parse via OrderSnapshot.fromJson)
  final Map<String, dynamic>? eventData;
  // event.reference_object (raw map, parse via OrderChangesRequest.fromJson)
  final Map<String, dynamic>? referenceData;
  // attachments dict for IMAGE/VIDEO/AUDIO/FILE frames per spec §4.4
  final Map<String, dynamic>? attachmentData;

  const ChatMessageModel({
    this.id,
    this.text,
    this.senderName,
    this.senderPhoto,
    this.isMe,
    this.createdAt,
    this.type,
    this.extraData,
    this.senderRole,
    this.messageType,
    this.eventType,
    this.eventData,
    this.referenceData,
    this.attachmentData,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender_data'] as Map<String, dynamic>?;
    final firstName = (senderData?['first_name'] as String?) ?? '';
    final lastName = (senderData?['last_name'] as String?) ?? '';
    final full = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final eventMap = json['event'] as Map<String, dynamic>?;
    final payload = eventMap?['payload'] is Map
        ? Map<String, dynamic>.from(eventMap!['payload'] as Map)
        : const <String, dynamic>{};

    // Different order events are not serialized identically by the backend.
    // Counter/status events usually expose order_object directly, while OTP,
    // completion, review and some notification events keep it in payload.
    final rawOrder = eventMap?['order_object'] ?? payload['order_object'];
    Map<String, dynamic>? eventData = rawOrder is Map
        ? Map<String, dynamic>.from(rawOrder)
        : null;

    // Last-resort identity keeps every order event attached to its canonical
    // card even when the event carries only order_id.
    final rawOrderId =
        eventMap?['order_id'] ?? payload['order_id'] ?? json['order_id'];
    if (eventData == null && rawOrderId is num) {
      eventData = {'id': rawOrderId.toInt()};
    }

    final rawReference =
        eventMap?['reference_object'] ?? payload['reference_object'];
    final referenceData = rawReference is Map
        ? Map<String, dynamic>.from(rawReference)
        : null;
    final attachments = json['attachments'];

    return ChatMessageModel(
      id: json['id'] as int?,
      text: json['content'] as String?,
      senderName: full.isNotEmpty ? full : json['sender'] as String?,
      senderPhoto: senderData?['photo'] as String?,
      isMe: null,
      createdAt: json['timestamp']?.toString(),
      type: json['message_type'] as String?,
      extraData: json['extra_data'] as Map<String, dynamic>?,
      senderRole: json['sender'] as String?,
      messageType: json['message_type'] as String?,
      eventType: (eventMap?['event_type'] ??
              payload['event_type'] ??
              json['event_type']) as String?,
      eventData: eventData,
      referenceData: referenceData,
      attachmentData: _firstAttachment(attachments),
    );
  }
}

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
      if (roomData == null)
        throw ApiException('Chat room not returned by server', body);
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
    return list
        .map(
          (e) => ChatRoomModel.fromJson(
            e as Map<String, dynamic>,
            isProviderView: false,
          ),
        )
        .toList();
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

  // Optional: If backend supports history by UUID
  Future<List<ChatMessageModel>> getMessagesByUuid(
    String uuid, {
    required String profileType, // 'provider' বা 'customer'
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
