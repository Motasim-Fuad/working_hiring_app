class TicketReplyModel {
  final int id;
  final int? replySender;
  final String? replySenderName;
  final String? senderType;
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
