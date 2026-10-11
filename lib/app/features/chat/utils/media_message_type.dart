import 'package:working_hiring/app/features/chat/models/message_type.dart';

bool isMediaMessageType(String t) =>
    t == 'IMAGE' || t == 'VIDEO' || t == 'AUDIO' || t == 'FILE';

MessageType mediaMessageTypeFor(String t) {
  switch (t) {
    case 'IMAGE':
      return MessageType.image;
    case 'VIDEO':
      return MessageType.video;
    case 'AUDIO':
      return MessageType.audio;
    default:
      return MessageType.file;
  }
}
