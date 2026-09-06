import 'package:flutter/foundation.dart';

/// Simple logger wrapper around Flutter's debugPrint.
/// Replaces the `logger(ApiClient)` pattern from the original project.
class AppLogger {
  final String tag;

  AppLogger(this.tag);

  void i(Object? message) => debugPrint('[$tag] INFO: $message');
  void d(Object? message) => debugPrint('[$tag] DEBUG: $message');
  void w(Object? message) => debugPrint('[$tag] WARN: $message');
  void e(Object? message) => debugPrint('[$tag] ERROR: $message');
}

AppLogger logger(Type type) => AppLogger(type.toString());
