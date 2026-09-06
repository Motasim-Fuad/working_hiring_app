import 'dart:async';

import 'package:get/get.dart';

import '../data/models/order_event.dart';

/// App-wide broadcast bus for `OrderEvent` frames.
///
/// Without this, order events would only be visible while `ChatView` is
/// mounted. The bus lets non-chat screens (Order list, My Jobs list, Order
/// detail) react to live transitions without REST polling.
///
/// Producers:
///   - `MessageController._onWsChatMessage` for `message_type == "EVENT"` frames.
///   - `WebSocketService.onNotification` callback when the notification frame's
///     `entity_type == "order"` (after enriching with the order detail).
///
/// Consumers subscribe with `events.listen(...)`.
class OrderEventBus extends GetxService {
  final StreamController<OrderEvent> _ctrl =
      StreamController<OrderEvent>.broadcast();

  Stream<OrderEvent> get events => _ctrl.stream;

  void emit(OrderEvent event) {
    if (_ctrl.isClosed) return;
    _ctrl.add(event);
  }

  @override
  void onClose() {
    _ctrl.close();
    super.onClose();
  }
}
