import 'package:get/get.dart';
import 'websocket_service.dart';

/// ✅ NEW FILE — fixes the "only one screen gets order updates" bug.
///
/// PROBLEM: WebSocketService.onNotification is a single callback field
/// (`void Function(Map<String, dynamic>)? onNotification`). Both
/// MessageController and OrderController need to react to notifications
/// (MessageController for chat badges, OrderController for live order
/// status / time-change updates on the order cards). Whichever
/// controller assigned `ws.onNotification = ...` LAST would silently
/// overwrite the other's handler — so only one of them ever actually
/// received notifications, while the other appeared "broken" with no
/// error anywhere.
///
/// FIX: This dispatcher is the ONLY thing that ever touches
/// WebSocketService.onNotification directly. It takes that one incoming
/// callback and fans it out to any number of registered listeners.
/// MessageController and OrderController each call
/// `NotificationDispatcher.instance.addListener(...)` instead of
/// touching ws.onNotification themselves — so they can never clobber
/// each other again, regardless of init order.
class NotificationDispatcher {
  NotificationDispatcher._internal();
  static final NotificationDispatcher instance =
  NotificationDispatcher._internal();

  final List<void Function(Map<String, dynamic> data)> _listeners = [];
  bool _hooked = false;

  /// Call once (safe to call multiple times) to make sure this
  /// dispatcher is the one wired into WebSocketService.onNotification.
  void ensureHooked() {
    if (_hooked) return;
    if (!Get.isRegistered<WebSocketService>()) return;
    final ws = Get.find<WebSocketService>();
    ws.onNotification = _dispatch;
    _hooked = true;
  }

  /// Register a listener. Returns a function you can call to remove it
  /// again (call from the owning controller's onClose).
  VoidCallback addListener(void Function(Map<String, dynamic> data) listener) {
    ensureHooked();
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  void _dispatch(Map<String, dynamic> data) {
    final payload = (data['type'] == 'notify' && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    // Iterate over a copy in case a listener removes itself mid-dispatch.
    for (final l in List.of(_listeners)) {
      try {
        l(payload);
      } catch (_) {
        // One listener's error must never stop the others from running.
      }
    }
  }
}

typedef VoidCallback = void Function();