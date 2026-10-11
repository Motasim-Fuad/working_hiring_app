/// Wire values for `event.event_type`. Constants — not an enum — because the
/// server may add new values, and the `ORDER_COMPLETEL` typo (sic) must be
/// matched literally per spec §8.
class OrderEventType {
  OrderEventType._();

  static const String orderCreated = 'ORDER_CREATED';
  static const String orderCounter = 'ORDER_COUNTER';
  static const String orderStatus = 'ORDER_STATUS';
  static const String orderCancel = 'ORDER_CANCEL';
  static const String orderChangeRequest = 'ORDER_CHANGE_REQUEST';
  static const String orderHourSet = 'ORDER_HOUR_SET';
  static const String orderWorkStart = 'ORDER_WORK_START';
  // Spec §8: backend literally emits "ORDER_COMPLETEL" with a trailing L.
  // Do not "fix" this — match exactly or the work-completed UI breaks.
  static const String orderCompleted = 'ORDER_COMPLETEL';
  static const String orderUpdated = 'ORDER_UPDATED';
}
