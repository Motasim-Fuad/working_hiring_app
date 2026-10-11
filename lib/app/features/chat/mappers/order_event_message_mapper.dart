import 'package:get/get.dart';

import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/features/chat/models/message_model.dart';
import 'package:working_hiring/app/features/chat/models/message_type.dart';

/// Turns backend order events into the chat timeline's order cards.
abstract final class OrderEventMessageMapper {
  static MessageModel build(
    OrderEvent event, {
    required bool isMe,
    required String senderRole,
    required int? chatMessageId,
    required String timestamp,
  }) {
    final order = event.order;
    final ref = event.reference;
    final backendStatus = order?.status ?? 'PENDING';
    var offerStatus = event.eventType == OrderEventType.orderCompleted
        ? 'completed'
        : mapOrderStatus(backendStatus, isMe);
    if (event.eventType == OrderEventType.orderCancel) {
      final cancelStatus = (ref?.status ?? '').toUpperCase();
      if (backendStatus.toUpperCase() == 'CANCELLED' ||
          cancelStatus == 'ACCEPT') {
        offerStatus = 'cancelled';
      } else if (cancelStatus == 'DECLINED' || cancelStatus == 'DECLINE') {
        // A declined cancellation restores the order to the status carried by
        // this authoritative event. This is especially important after work
        // has started: IN_PROGRESS must not fall back to a stale cancellation
        // card (or to the generic paid state).
        offerStatus = mapOrderStatus(backendStatus, isMe);
        if (offerStatus == 'pending' || offerStatus == 'sent') {
          offerStatus = (order?.paymentStatus ?? '').toUpperCase() == 'PAID'
              ? 'paid'
              : 'pending';
        }
      } else if (cancelStatus.isEmpty ||
          cancelStatus == 'PENDING' ||
          cancelStatus == 'NO_RESPONSE') {
        offerStatus = 'cancellationRequested';
      }
    }
    DateTime? workingDate;
    final dateStr = order?.workingDate;
    if (dateStr != null) workingDate = DateTime.tryParse(dateStr);

    final amountFromRef = ref?.proposedBudget;
    final amount = amountFromRef ?? order?.amount;

    final String? duration = order?.workingHour != null
        ? '${order!.workingHour} hour${order.workingHour! > 1 ? 's' : ''}'
        : null;

    return MessageModel(
      id: chatMessageId,
      text: _summaryFor(event.eventType, ref),
      isMe: isMe,
      senderRole: senderRole,
      time: timestamp,
      type: _typeForEvent(event.eventType),
      taskTitle: order?.title,
      address: order?.area,
      date: workingDate,
      timeSlot: order?.workingStartTime,
      endTime: order?.endTime,
      proposedBudget: amount,
      description: order?.description,
      offerStatus: offerStatus,
      jobState: backendStatus.toLowerCase(),
      orderId: order?.id,
      eventType: event.eventType,
      changesRequestId: ref?.id,
      changesType: ref?.changesType,
      changesRequestStatus: ref?.status,
      proposedHour: ref?.proposedHour,
      proposedDateStr: ref?.proposedDate,
      proposedTime: ref?.proposedTime,
      proposedMessage: ref?.message,
      cancellationReason: event.eventType == OrderEventType.orderCancel
          ? ref?.message
          : null,
      counterMessage:
          (event.eventType.toUpperCase() == OrderEventType.orderCounter ||
              ref?.changesType == 'COUNTER')
          ? ref?.message
          : null,
      isRescheduleRequest:
          ref?.changesType == 'TIME' ||
          ref?.changesType == 'DATE' ||
          ref?.changesType == 'TIME_AND_DATE',

      duration: duration,
      workCompleted: event.eventType == OrderEventType.orderCompleted,
    );
  }

  /// ORDER_CREATED may reach one participant after a normal chat message even
  /// though the order itself was created first. For that initial card only,
  /// use the order's creation time so both participants get the same
  /// chronology. Every later event keeps its own event/message timestamp and
  /// therefore moves the canonical card to the bottom as intended.
  static String timelineTimestamp(OrderEvent event, String fallback) {
    if (event.eventType == OrderEventType.orderCreated) {
      final createdAt = event.order?.createdAt;
      if (createdAt != null && createdAt.isNotEmpty) return createdAt;
    }
    return fallback;
  }

  static String mapOrderStatus(String backendStatus, bool isMe) {
    switch (backendStatus.toUpperCase()) {
      case 'ACCEPT':
        return 'accepted';
      case 'CONFIRM':
        return 'paid';
      case 'IN_PROGRESS':
        return 'inProgress';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLATION_REQUEST':
        return 'cancellationRequested';
      case 'CANCELLED':
        return 'cancelled';
      case 'REFUND_REQUEST':
        return 'refundPending';
      case 'REFUND':
        return 'refunded';
      default:
        return isMe ? 'sent' : 'pending';
    }
  }

  static MessageType _typeForEvent(String eventType) {
    switch (eventType) {
      case OrderEventType.orderCreated:
      case OrderEventType.orderCounter:
      case OrderEventType.orderStatus:
      case OrderEventType.orderUpdated:
        return MessageType.offer;
      case OrderEventType.orderCancel:
      case OrderEventType.orderChangeRequest:
      case OrderEventType.orderHourSet:
      case OrderEventType.orderWorkStart:
      case OrderEventType.orderCompleted:
        return MessageType.systemEvent;
      default:
        return MessageType.systemEvent;
    }
  }

  static String _summaryFor(String eventType, OrderChangesRequest? ref) {
    switch (eventType) {
      case OrderEventType.orderCreated:
        return 'Order requested'.tr;
      case OrderEventType.orderCounter:
        final budget = ref?.proposedBudget;
        return budget != null
            ? 'Counter Offer Value'.trParams({
                'amount': '\$${budget.toStringAsFixed(2)}',
              })
            : 'Counter offer'.tr;
      case OrderEventType.orderStatus:
        return 'Order status updated'.tr;
      case OrderEventType.orderCancel:
        return 'Cancellation request'.tr;
      case OrderEventType.orderChangeRequest:
        return 'New time proposed'.tr;
      case OrderEventType.orderHourSet:
        return 'Updated estimated hours'.tr;
      case OrderEventType.orderWorkStart:
        return 'Work started'.tr;
      case OrderEventType.orderCompleted:
        return 'Work completed'.tr;
      case OrderEventType.orderUpdated:
        return 'Order updated'.tr;
      default:
        return 'Order event'.tr;
    }
  }
}
