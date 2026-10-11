import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/features/chat/models/message_model.dart';
import 'package:working_hiring/app/features/chat/utils/message_timeline.dart';

MessageModel _msg(int? id, String time) =>
    MessageModel(id: id, text: 't', isMe: true, time: time);

void main() {
  group('compareMessageTimeline', () {
    test('orders persisted messages by server id, not timestamp', () {
      final list = [
        _msg(5, '2026-01-01T10:00:00Z'),
        _msg(3, '2026-01-01T12:00:00Z'),
      ]..sort(compareMessageTimeline);

      expect(list.map((m) => m.id), [3, 5]);
    });

    test('keeps optimistic (negative id) messages last', () {
      final list = [_msg(-1, 'Now'), _msg(10, '2026-01-01T10:00:00Z')]
        ..sort(compareMessageTimeline);

      expect(list.map((m) => m.id), [10, -1]);
    });

    test('falls back to timestamps when ids are missing', () {
      final list = [
        _msg(null, '2026-01-02T00:00:00Z'),
        _msg(null, '2026-01-01T00:00:00Z'),
      ]..sort(compareMessageTimeline);

      expect(list.first.time, '2026-01-01T00:00:00Z');
    });

    test('messages without a parsable time sort after timed ones', () {
      final list = [_msg(null, 'Now'), _msg(null, '2026-01-01T00:00:00Z')]
        ..sort(compareMessageTimeline);

      expect(list.last.time, 'Now');
    });
  });

  test('parseMessageTime handles placeholders', () {
    expect(parseMessageTime('Now'), isNull);
    expect(parseMessageTime(''), isNull);
    expect(parseMessageTime('garbage'), isNull);
    expect(parseMessageTime('2026-01-01T00:00:00Z'), isNotNull);
  });
}
