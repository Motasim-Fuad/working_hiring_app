import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/features/chat/models/message_type.dart';
import 'package:working_hiring/app/features/chat/utils/media_message_type.dart';
import 'package:working_hiring/app/features/chat/utils/media_url.dart';
import 'package:working_hiring/app/features/chat/utils/time_ago.dart';

void main() {
  test('formatTimeAgo buckets durations', () {
    String ago(Duration d) =>
        formatTimeAgo(DateTime.now().subtract(d).toUtc().toIso8601String());

    expect(formatTimeAgo(null), '');
    expect(formatTimeAgo('not a date'), 'not a date');
    expect(ago(const Duration(seconds: 10)), 'now');
    expect(ago(const Duration(minutes: 5)), '5m');
    expect(ago(const Duration(hours: 3)), '3h');
    expect(ago(const Duration(days: 2)), '2d');
    expect(ago(const Duration(days: 15)), '2w');
  });

  test('media message type mapping', () {
    expect(isMediaMessageType('IMAGE'), isTrue);
    expect(isMediaMessageType('TEXT'), isFalse);
    expect(mediaMessageTypeFor('VIDEO'), MessageType.video);
    expect(mediaMessageTypeFor('PDF'), MessageType.file);
  });

  test('absoluteMediaUrl keeps absolute URLs and prefixes relative ones', () {
    expect(absoluteMediaUrl(null), '');
    expect(absoluteMediaUrl('https://x.com/a.png'), 'https://x.com/a.png');
    expect(absoluteMediaUrl('/media/a.png'), endsWith('/media/a.png'));
    expect(absoluteMediaUrl('media/a.png'), startsWith('http'));
  });
}
