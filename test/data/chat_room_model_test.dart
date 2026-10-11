import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';

void main() {
  group('ChatRoomModel.fromJson (customer view)', () {
    test('never exposes the provider personal name from other_user', () {
      final room = ChatRoomModel.fromJson({
        'uuid': 'abc',
        'other_user': {'first_name': 'John', 'last_name': 'Doe', 'photo': 'p'},
        'unread_count': 2,
      }, isProviderView: false);

      expect(room.name, isNull);
      expect(room.photo, isNull);
      expect(room.unreadCount, 2);
    });

    test('uses provider company_name and logo when present', () {
      final room = ChatRoomModel.fromJson({
        'uuid': 'abc',
        'provider': {'company_name': '  Acme Ltd ', 'logo': 'logo.png'},
      }, isProviderView: false);

      expect(room.name, 'Acme Ltd');
      expect(room.photo, 'logo.png');
    });

    test('blank company_name resolves to null', () {
      final room = ChatRoomModel.fromJson({
        'uuid': 'abc',
        'provider': {'company_name': '   '},
      }, isProviderView: false);

      expect(room.name, isNull);
    });
  });

  group('ChatRoomModel.fromJson (provider view)', () {
    test('uses customer full name from other_user', () {
      final room = ChatRoomModel.fromJson({
        'uuid': 'abc',
        'room_id': 7,
        'other_user': {'first_name': 'Jane', 'last_name': 'Roe', 'photo': 'x'},
        'last_message': {'content': 'hi', 'timestamp': '2026-01-01'},
      }, isProviderView: true);

      expect(room.id, 7);
      expect(room.name, 'Jane Roe');
      expect(room.photo, 'x');
      expect(room.lastMessage, 'hi');
      expect(room.lastMessageTime, '2026-01-01');
    });

    test('falls back to customer map', () {
      final room = ChatRoomModel.fromJson({
        'uuid': 'abc',
        'customer': {'first_name': 'Jane', 'last_name': ''},
      }, isProviderView: true);

      expect(room.name, 'Jane');
    });
  });

  test('copyWith only replaces given fields', () {
    const room = ChatRoomModel(id: 1, uuid: 'u', name: 'A', photo: 'p');
    final updated = room.copyWith(name: 'B');

    expect(updated.name, 'B');
    expect(updated.photo, 'p');
    expect(updated.uuid, 'u');
    expect(updated.id, 1);
  });
}
