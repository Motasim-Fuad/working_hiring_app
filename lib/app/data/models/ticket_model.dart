// lib/data/models/ticket_model.dart
class TicketModel {
  final int id;
  final int? user;
  final String? userName;
  final String? userProfileType;
  final String subject;
  final int? order;
  final String status;
  final String summary;
  final String? attachment;
  final String? lastMessage;
  final String? lastReplyAt;
  final String createdAt;
  final String updatedAt;
  final List<TicketReplyModel> replies;

  TicketModel({
    required this.id,
    this.user,
    this.userName,
    this.userProfileType,
    required this.subject,
    this.order,
    required this.status,
    required this.summary,
    this.attachment,
    this.lastMessage,
    this.lastReplyAt,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      user: json['user'] as int?,
      userName: json['user_name'] as String?,
      userProfileType: json['user_profile_type'] as String?,
      subject: json['subject'] as String? ?? '',
      order: json['order'] as int?,
      status: json['status'] as String? ?? 'open',
      summary: json['summary'] as String? ?? '',
      attachment: json['attachment'] as String?,
      lastMessage: json['last_message'] as String?,
      lastReplyAt: json['last_reply_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      replies: (json['replies'] as List?)
          ?.map((e) => TicketReplyModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'subject': subject,
    'status': status,
    'date': createdAt,
    'order': order,
    'summary': summary,
    'attachment': attachment,
  };
}

class TicketReplyModel {
  final int id;
  final int? replySender;
  final String? replySenderName;
  final String? senderType; // "USER" or "ADMIN"
  final String message;
  final String? attachment;
  final String createdAt;

  TicketReplyModel({
    required this.id,
    this.replySender,
    this.replySenderName,
    this.senderType,
    required this.message,
    this.attachment,
    required this.createdAt,
  });

  factory TicketReplyModel.fromJson(Map<String, dynamic> json) {
    return TicketReplyModel(
      id: json['id'] as int,
      replySender: json['reply_sender'] as int?,
      replySenderName: json['reply_sender_name'] as String?,
      senderType: json['sender_type'] as String?,
      message: json['message'] as String? ?? '',
      attachment: json['attachment'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}