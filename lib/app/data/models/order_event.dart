/// Strongly-typed models for the WebSocket `EVENT` frame payload.
/// Mirrors spec §4.5 of WEBSOCKET_ORDER_DOCUMENTATION.md exactly.
library;

/// Wire values for `event.event_type`. Constants — not an enum — because the
/// server may add new values, and the `ORDER_COMPLETEL` typo (sic) must be
/// matched literally per spec §8.
class OrderEventType {
  OrderEventType._();

  static const String orderCreated = 'ORDER_CREATED';
  static const String orderCounter = 'ORDER_COUNTER';
  static const String orderStatus = 'ORDER_STATUS';
  static const String orderCancel = 'ORDER_CANCEL';
  static const String orderChangeRequest = 'ORDER_CHANGE_REQUEST';
  static const String orderHourSet = 'ORDER_HOUR_SET';
  static const String orderWorkStart = 'ORDER_WORK_START';
  // Spec §8: backend literally emits "ORDER_COMPLETEL" with a trailing L.
  // Do not "fix" this — match exactly or the work-completed UI breaks.
  static const String orderCompleted = 'ORDER_COMPLETEL';
  static const String orderUpdated = 'ORDER_UPDATED';
}

class OrderSnapshot {
  final int id;
  final String? title;
  final String? description;
  final String? area;
  final double? amount;
  final String? status;
  final String? paymentStatus;
  final String? workingDate;
  final String? workingStartTime;
  final int? workingHour;
  final String? endTime;
  final String? endDatetime;
  final String? createdAt;

  OrderSnapshot({
    required this.id,
    this.title,
    this.description,
    this.area,
    this.amount,
    this.status,
    this.paymentStatus,
    this.workingDate,
    this.workingStartTime,
    this.workingHour,
    this.endTime,
    this.endDatetime,
    this.createdAt,
  });

  factory OrderSnapshot.fromJson(Map<String, dynamic> j) => OrderSnapshot(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: j['title'] as String?,
    description: j['description'] as String?,
    area: j['area'] as String?,
    amount: double.tryParse(j['amount']?.toString() ?? ''),
    status: j['status'] as String?,
    paymentStatus: j['payment_status'] as String?,
    workingDate: j['working_date'] as String?,
    workingStartTime: j['working_start_time'] as String?,
    workingHour: (j['working_hour'] as num?)?.toInt(),
    endTime: j['end_time'] as String?,
    endDatetime: j['end_datetime'] as String?,
    createdAt: j['created_at'] as String?,
  );
}

/// Wire schema for `event.reference_object` — populated for COUNTER, CANCEL,
/// CHANGE_REQUEST, and HOUR_SET events. Carries the `OrderChangesRequest.id`
/// the receiver echoes back when responding via REST.
class OrderChangesRequest {
  final int id;
  final String? requestBy; // "CUSTOMER" | "PROVIDER"
  final String? status; // "ACCEPT" | "DECLINED" | "NO_RESPONSE"
  final String?
  changesType; // TIME | DATE | TIME_AND_DATE | AMOUNT | COUNTER | SET_HOUR | CANCEL
  final Map<String, dynamic> changesData;
  final String? createdAt;
  final String? updatedAt;

  OrderChangesRequest({
    required this.id,
    this.requestBy,
    this.status,
    this.changesType,
    this.changesData = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory OrderChangesRequest.fromJson(Map<String, dynamic> j) {
    final changesData = (j['changes_data'] is Map)
        ? Map<String, dynamic>.from(j['changes_data'] as Map)
        : <String, dynamic>{};
    if (!changesData.containsKey('budget')) {
      final budget = j['proposed_budget'] ?? j['budget'];
      if (budget != null) changesData['budget'] = budget;
    }
    if (!changesData.containsKey('message') && j['message'] != null) {
      changesData['message'] = j['message'];
    }
    return OrderChangesRequest(
      id: (j['id'] as num?)?.toInt() ?? 0,
      requestBy: j['request_by'] as String?,
      status: j['status'] as String?,
      changesType: j['changes_type'] as String?,
      changesData: changesData,
      createdAt: j['created_at'] as String?,
      updatedAt: j['updated_at'] as String?,
    );
  }

  /// Proposed budget for COUNTER events. Always returned as string per spec §2.2.
  double? get proposedBudget =>
      double.tryParse(changesData['budget']?.toString() ?? '');

  /// Proposed working date for TIME/DATE/TIME_AND_DATE events ("YYYY-MM-DD").
  String? get proposedDate => changesData['date'] as String?;

  /// Proposed working time for TIME/TIME_AND_DATE events (e.g. "10:00 AM").
  String? get proposedTime => changesData['time'] as String?;

  /// Proposed work hour for SET_HOUR events.
  int? get proposedHour => (changesData['set_hour'] as num?)?.toInt();

  /// Free-text message attached to the proposal.
  String? get message => changesData['message'] as String?;
}

class OrderEvent {
  final int id;
  final String eventType;
  final OrderSnapshot? order;
  final OrderChangesRequest? reference;
  final String? createdAt;
  final String? updatedAt;

  /// Echoed top-level fields from the outer chat-message frame — useful
  /// when downstream consumers need to know who triggered the event.
  final String? sender; // "CUSTOMER" | "PROVIDER"
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
