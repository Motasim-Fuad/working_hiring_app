/// Strongly-typed models for the WebSocket `EVENT` frame payload.
/// Mirrors spec §4.5 of WEBSOCKET_ORDER_DOCUMENTATION.md exactly.
library;

import 'package:working_hiring/app/data/models/order_event_type.dart';
import 'package:working_hiring/app/data/models/order_snapshot.dart';
import 'package:working_hiring/app/data/models/order_changes_request.dart';
export 'package:working_hiring/app/data/models/order_event_type.dart';
export 'package:working_hiring/app/data/models/order_snapshot.dart';
export 'package:working_hiring/app/data/models/order_changes_request.dart';

class OrderEvent {
  final int id;
  final String eventType;
  final OrderSnapshot? order;
  final OrderChangesRequest? reference;
  final String? createdAt;
  final String? updatedAt;

  /// Echoed top-level fields from the outer chat-message frame — useful
  /// when downstream consumers need to know who triggered the event.
  final String? sender;
  final int? chatMessageId;
  final String? timestamp;
  final String? roomUuid;

  OrderEvent({
    required this.id,
    required this.eventType,
    this.order,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.chatMessageId,
    this.timestamp,
    this.roomUuid,
  });

  /// Builds from the full outer chat_message frame (spec §4.5).
  factory OrderEvent.fromChatFrame(
    Map<String, dynamic> frame, {
    String? roomUuid,
  }) {
    final ev = frame['event'] as Map<String, dynamic>? ?? const {};
    final payload = ev['payload'] is Map
        ? Map<String, dynamic>.from(ev['payload'] as Map)
        : const <String, dynamic>{};
    final orderObj = ev['order_object'] ?? payload['order_object'];
    final refObj = ev['reference_object'] ?? payload['reference_object'];
    final rawOrderId =
        ev['order_id'] ?? payload['order_id'] ?? frame['order_id'];
    final fallbackOrder = orderObj is Map
        ? Map<String, dynamic>.from(orderObj)
        : rawOrderId is num
        ? <String, dynamic>{'id': rawOrderId.toInt()}
        : null;
    return OrderEvent(
      id: (ev['id'] as num?)?.toInt() ?? (payload['id'] as num?)?.toInt() ?? 0,
      eventType: (ev['event_type'] ?? payload['event_type']) as String? ?? '',
      order: fallbackOrder != null
          ? OrderSnapshot.fromJson(fallbackOrder)
          : null,
      reference: refObj is Map
          ? OrderChangesRequest.fromJson(Map<String, dynamic>.from(refObj))
          : null,
      createdAt: (ev['created_at'] ?? payload['created_at'])?.toString(),
      updatedAt: (ev['updated_at'] ?? payload['updated_at'])?.toString(),
      sender: frame['sender'] as String?,
      chatMessageId: frame['id'] as int?,
      timestamp: frame['timestamp'] as String?,
      roomUuid: roomUuid,
    );
  }

  /// True when the event represents work completion. Hides the
  /// `ORDER_COMPLETEL` typo from callers.
  bool get isWorkCompleted => eventType == OrderEventType.orderCompleted;

  /// True for status-like events that should update an existing card in place
  /// rather than appending a new one.
  bool get isStatusTransition =>
      eventType == OrderEventType.orderStatus ||
      eventType == OrderEventType.orderUpdated;
}
