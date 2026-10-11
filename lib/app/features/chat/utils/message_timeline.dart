import 'package:working_hiring/app/features/chat/models/message_model.dart';

DateTime? parseMessageTime(String timeStr) {
  if (timeStr == 'Now' || timeStr.isEmpty) return null;
  try {
    return DateTime.parse(timeStr);
  } catch (_) {
    return null;
  }
}

/// Shared by the controller and ChatView's defensive render snapshot so a
/// reactive rebuild can never fall back to WebSocket arrival order.
int compareMessageTimeline(MessageModel a, MessageModel b) {
  // A WebSocket frame can arrive out of order and some frames omit a
  // usable timestamp. Positive chat-message ids are assigned by the
  // backend in creation order, so they are the most reliable chronology
  // for persisted messages. This keeps ORDER_CREATED before messages sent
  // after it even when that event reaches one participant late. A later
  // counter/status event has a newer id, so the canonical card still moves
  // to the bottom on every real order update.
  final idA = a.id;
  final idB = b.id;
  final hasServerIdA = idA != null && idA > 0;
  final hasServerIdB = idB != null && idB > 0;
  if (hasServerIdA && hasServerIdB && idA != idB) {
    return idA.compareTo(idB);
  }

  // Optimistic local messages use negative ids. Until their server echo
  // replaces them with a positive id, they must remain the latest item.
  if (!hasServerIdA && hasServerIdB && (a.isTemporary || (idA ?? 0) < 0)) {
    return 1;
  }
  if (hasServerIdA && !hasServerIdB && (b.isTemporary || (idB ?? 0) < 0)) {
    return -1;
  }

  final DateTime? timeA = parseMessageTime(a.time);
  final DateTime? timeB = parseMessageTime(b.time);
  if (timeA == null && timeB == null) return 0;
  if (timeA == null) return 1;
  if (timeB == null) return -1;
  return timeA.compareTo(timeB);
}
