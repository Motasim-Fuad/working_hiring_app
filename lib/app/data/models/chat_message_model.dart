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

class ChatMessageModel {
  final int? id;
  final String? text;
  final String? senderName;
  final String? senderPhoto;
  final bool? isMe;
  final String? createdAt;
  final String? type;
  final Map<String, dynamic>? extraData;
  final String? senderRole;
  final String? messageType;
  final String? eventType;
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? referenceData;
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
      eventType:
          (eventMap?['event_type'] ??
                  payload['event_type'] ??
                  json['event_type'])
              as String?,
      eventData: eventData,
      referenceData: referenceData,
      attachmentData: _firstAttachment(attachments),
    );
  }
}
