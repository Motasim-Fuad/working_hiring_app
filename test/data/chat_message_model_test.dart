import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';

void main() {
  group('ChatMessageModel.fromJson', () {
    test('reads order_object directly from event', () {
      final msg = ChatMessageModel.fromJson({
        'id': 1,
        'message_type': 'EVENT',
        'sender': 'PROVIDER',
        'event': {
          'event_type': 'COUNTER',
          'order_object': {'id': 42},
        },
      });

      expect(msg.eventType, 'COUNTER');
      expect(msg.eventData, {'id': 42});
      expect(msg.senderRole, 'PROVIDER');
    });

    test('reads order_object from event payload', () {
      final msg = ChatMessageModel.fromJson({
        'event': {
          'payload': {
            'event_type': 'OTP',
            'order_object': {'id': 9},
          },
        },
      });

      expect(msg.eventType, 'OTP');
      expect(msg.eventData?['id'], 9);
    });

    test('falls back to order_id when no order_object exists', () {
      final msg = ChatMessageModel.fromJson({
        'event': {'event_type': 'REVIEW', 'order_id': 5},
      });

      expect(msg.eventData, {'id': 5});
    });

    test('normalizes attachments list to its first entry', () {
      final msg = ChatMessageModel.fromJson({
        'message_type': 'IMAGE',
        'attachments': [
          {'file_url': 'a.png'},
          {'file_url': 'b.png'},
        ],
      });

      expect(msg.attachmentData, {'file_url': 'a.png'});
    });

    test('accepts a single attachment map', () {
      final msg = ChatMessageModel.fromJson({
        'attachments': {'file_url': 'a.png'},
      });

      expect(msg.attachmentData?['file_url'], 'a.png');
    });

    test('builds sender name from sender_data', () {
      final msg = ChatMessageModel.fromJson({
        'sender': 'CUSTOMER',
        'sender_data': {'first_name': 'Ann', 'last_name': 'Lee'},
      });

      expect(msg.senderName, 'Ann Lee');
    });
  });
}
