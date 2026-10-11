import 'package:get/get.dart';

import 'package:working_hiring/app/features/chat/models/message_model.dart';

class ChatModel {
  final String name;
  final String avatar;
  final String lastMessage;
  final String timeAgo;
  final bool isOnline;
  final bool hasUnread;
  final String? roomUuid;
  final int? roomId;
  final RxList<MessageModel> messages;

  ChatModel({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timeAgo,
    this.isOnline = false,
    this.hasUnread = false,
    this.roomUuid,
    this.roomId,
    List<MessageModel> messages = const [],
  }) : messages = messages.obs;
}
