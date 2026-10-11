import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/features/chat/mappers/order_event_message_mapper.dart';
import 'package:working_hiring/app/features/chat/models/message_type.dart';

OrderEvent _event(
  String type, {
  String status = 'PENDING',
  String? paymentStatus,
  Map<String, dynamic>? reference,
  String? createdAt,
}) => OrderEvent(
  id: 1,
  eventType: type,
  order: OrderSnapshot.fromJson({
    'id': 42,
    'title': 'Fix sink',
    'status': status,
    'payment_status': paymentStatus,
    'working_hour': 2,
    'amount': '50',
    'created_at': createdAt,
  }),
  reference: reference == null ? null : OrderChangesRequest.fromJson(reference),
);

void main() {
  setUp(() => Get.testMode = true);

  group('mapOrderStatus', () {
    test('maps backend statuses to card states', () {
      expect(
        OrderEventMessageMapper.mapOrderStatus('ACCEPT', false),
        'accepted',
      );
      expect(OrderEventMessageMapper.mapOrderStatus('confirm', false), 'paid');
      expect(
        OrderEventMessageMapper.mapOrderStatus('IN_PROGRESS', false),
        'inProgress',
      );
      expect(
        OrderEventMessageMapper.mapOrderStatus('REFUND', true),
        'refunded',
      );
    });

    test('unknown status depends on who sent it', () {
      expect(OrderEventMessageMapper.mapOrderStatus('PENDING', true), 'sent');
      expect(
        OrderEventMessageMapper.mapOrderStatus('PENDING', false),
        'pending',
      );
    });
  });

  group('build', () {
    test('order created becomes an offer card for the order', () {
      final msg = OrderEventMessageMapper.build(
        _event(OrderEventType.orderCreated),
        isMe: false,
        senderRole: 'client',
        chatMessageId: 7,
        timestamp: '2026-01-01T00:00:00Z',
      );

      expect(msg.id, 7);
      expect(msg.orderId, 42);
      expect(msg.type, MessageType.offer);
      expect(msg.offerStatus, 'pending');
      expect(msg.duration, '2 hours');
      expect(msg.taskTitle, 'Fix sink');
    });

    test('completed event marks work completed', () {
      final msg = OrderEventMessageMapper.build(
        _event(OrderEventType.orderCompleted, status: 'IN_PROGRESS'),
        isMe: true,
        senderRole: 'provider',
        chatMessageId: 8,
        timestamp: 'Now',
      );

      expect(msg.offerStatus, 'completed');
      expect(msg.workCompleted, isTrue);
      expect(msg.type, MessageType.systemEvent);
    });

    test('declined cancellation restores paid state', () {
      final msg = OrderEventMessageMapper.build(
        _event(
          OrderEventType.orderCancel,
          status: 'PENDING',
          paymentStatus: 'PAID',
          reference: {'id': 1, 'status': 'DECLINED'},
        ),
        isMe: false,
        senderRole: 'client',
        chatMessageId: 9,
        timestamp: 'Now',
      );

      expect(msg.offerStatus, 'paid');
    });

    test('pending cancellation shows cancellation requested', () {
      final msg = OrderEventMessageMapper.build(
        _event(
          OrderEventType.orderCancel,
          status: 'CONFIRM',
          reference: {'id': 1, 'status': 'PENDING', 'message': 'sick'},
        ),
        isMe: false,
        senderRole: 'client',
        chatMessageId: 10,
        timestamp: 'Now',
      );

      expect(msg.offerStatus, 'cancellationRequested');
      expect(msg.cancellationReason, 'sick');
    });
  });

  test('timelineTimestamp uses order creation time only for ORDER_CREATED', () {
    final created = _event(
      OrderEventType.orderCreated,
      createdAt: '2026-01-01T00:00:00Z',
    );
    final status = _event(
      OrderEventType.orderStatus,
      createdAt: '2026-01-01T00:00:00Z',
    );

    expect(
      OrderEventMessageMapper.timelineTimestamp(created, 'fallback'),
      '2026-01-01T00:00:00Z',
    );
    expect(
      OrderEventMessageMapper.timelineTimestamp(status, 'fallback'),
      'fallback',
    );
  });
}
