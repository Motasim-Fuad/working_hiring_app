import 'package:working_hiring/app/data/utils/json_parsers.dart';

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

    final otherUser = json['other_user'] as Map<String, dynamic>?;
    if (!isProviderView) {
      // Customers must only ever see the provider's company name, never the
      // provider's personal first/last name. The room list does not include
      // it, so ChatRepository resolves it later via the room's order.
      final provider = json['provider'];
      if (provider is Map) {
        name = nonEmptyString(provider['company_name']);
        photo = nonEmptyString(provider['logo']);
      }
    } else if (otherUser != null) {
      final firstName = (otherUser['first_name'] as String?) ?? '';
      final lastName = (otherUser['last_name'] as String?) ?? '';
      final full = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      name = full.isNotEmpty ? full : null;
      photo = otherUser['photo'] as String?;
    } else {
      final customer = json['customer'] as Map<String, dynamic>?;
      final firstName = (customer?['first_name'] as String?) ?? '';
      final lastName = (customer?['last_name'] as String?) ?? '';
      final full = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      name = full.isNotEmpty ? full : null;
      photo = customer?['photo'] as String?;
    }

    final lastMessageObj = json['last_message'] as Map<String, dynamic>?;
    final lastMessageContent = lastMessageObj?['content'] as String?;
    final lastMessageTimestamp = lastMessageObj?['timestamp']?.toString();

    return ChatRoomModel(
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

  ChatRoomModel copyWith({String? name, String? photo}) => ChatRoomModel(
    id: id,
    uuid: uuid,
    name: name ?? this.name,
    photo: photo ?? this.photo,
    lastMessage: lastMessage,
    lastMessageTime: lastMessageTime,
    isOnline: isOnline,
    unreadCount: unreadCount,
  );
}
