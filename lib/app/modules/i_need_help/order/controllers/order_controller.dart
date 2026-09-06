import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/models/order_model.dart';
import '../../../../../app/data/models/order_event.dart';
import '../../../../../app/service/api_service.dart';
import '../../../../../app/service/order_event_bus.dart';
import '../../../../../app/service/reviewed_orders.dart';
import '../../../../../app/service/notification_dispatcher.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepo;

  OrderController(this._orderRepo);

  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<OrderEvent>? _busSub;
  VoidCallback? _notifyUnsub;

  final Set<int> _orderIds = {};

  /// ✅ Tracks orders where provider has sent a counter.
  /// Populated from OrderEventBus ORDER_COUNTER events (real-time)
  /// and from API changes_requests when available.
  final Set<int> _providerCounteredIds = {};

  /// ✅ Session-based client counter tracking.
  final Set<int> _clientCounterSentIds = {};

  /// ✅ NEW: Tracks pending time-change requests pushed via WebSocket
  /// (ORDER_CHANGE_REQUEST event), keyed by orderId. This is the
  /// reliable source since the order list API doesn't always include
  /// changes_requests. Cleared once the client responds (Accept/Decline).
  final RxMap<int, ChangesRequestModel> _liveTimeChangeRequests =
      <int, ChangesRequestModel>{}.obs;

  /// Returns the active pending time-change request for an order, if any.
  /// Checks the live WebSocket-driven map first, then falls back to the
  /// API's changes_requests (when present).
  ChangesRequestModel? pendingTimeChangeFor(int orderId) {
    if (_liveTimeChangeRequests.containsKey(orderId)) {
      return _liveTimeChangeRequests[orderId];
    }
    final order = allOrders.where((o) => o.id == orderId).firstOrNull;
    return order?.pendingTimeChangeRequest;
  }

  /// True if provider has countered this order.
  /// Checks: (1) real-time event bus Set, (2) API changes_requests
  bool hasProviderCountered(int orderId) {
    if (_providerCounteredIds.contains(orderId)) return true;
    final order = allOrders.where((o) => o.id == orderId).firstOrNull;
    final action = (order?.orderChangeAction ?? '').toUpperCase();
    if (action == 'PROVIDER_COUNTER_SEND' ||
        action == 'CUSTOMER_COUNTER_SEND') {
      return true;
    }
    return order?.providerAlreadyCountered ?? false;
  }

  /// True if client has already sent a counter for this order.
  bool hasClientCountered(int orderId) {
    if (_clientCounterSentIds.contains(orderId)) return true;
    final order = allOrders.where((o) => o.id == orderId).firstOrNull;
    if ((order?.orderChangeAction ?? '').toUpperCase() ==
        'CUSTOMER_COUNTER_SEND') {
      return true;
    }
    if (order?.changesRequests == null) return false;
    return order!.changesRequests!.any((r) =>
    r.isCounter && (r.sender ?? '').toUpperCase() == 'CUSTOMER');
  }

  List<OrderModel> get createdOrders =>
      allOrders.where((o) => o.effectiveStatus == 'PENDING').toList();
  List<OrderModel> get inProgressOrders =>
      allOrders
          .where((o) =>
      o.effectiveStatus == 'IN_PROGRESS' ||
          o.effectiveStatus == 'ACCEPT' ||
          o.effectiveStatus == 'CONFIRM' ||
          o.effectiveStatus == 'CANCELLATION_REQUEST')
          .toList();
  List<OrderModel> get completedOrders =>
      allOrders.where((o) => o.effectiveStatus == 'COMPLETED').toList();
  List<OrderModel> get cancelledOrders =>
      allOrders.where((o) => o.effectiveStatus == 'CANCELLED').toList();
  List<OrderModel> get confirmOrders =>
      allOrders
          .where((o) =>
              o.effectiveStatus == 'CONFIRM' ||
              o.effectiveStatus == 'CANCELLATION_REQUEST' ||
              o.effectiveStatus == 'ACCEPT')
          .toList();

  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final RxBool isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _subscribeToBus();

    // ✅ Safe, non-clobbering notification listener.
    // See notification_dispatcher.dart for why this exists: directly
    // assigning ws.onNotification here would silently overwrite
    // MessageController's chat-badge listener (or vice versa), since
    // WebSocketService only supports ONE onNotification callback.
    _notifyUnsub = NotificationDispatcher.instance.addListener((data) {
      final entityType = (data['entity_type'] as String?)?.toLowerCase();
      final entityId = data['entity'];
      if (entityType == 'order' && entityId is int) {
        // Pull fresh data for ALL orders. Cheap, and it's the only way
        // to pick up a provider's new time-change request without
        // already being inside the relevant chat room.
        _reloadOrdersWithDedup();
      }
    });
  }

  @override
  void onClose() {
    _busSub?.cancel();
    _notifyUnsub?.call();
    super.onClose();
  }

  void _subscribeToBus() {
    if (!Get.isRegistered<OrderEventBus>()) return;
    final bus = Get.find<OrderEventBus>();
    _busSub = bus.events.listen((event) {
      if (event.order?.id == null) return;
      final orderId = event.order!.id!;

      if (event.eventType == OrderEventType.orderCounter) {
        final sender = (event.sender ?? '').toUpperCase().trim();
        if (sender == 'PROVIDER') {
          _providerCounteredIds.add(orderId);
        } else if (sender == 'CUSTOMER') {
          _clientCounterSentIds.add(orderId);
        }
        allOrders.refresh();
      }

      // ✅ NEW: Provider proposed a new time — surface Accept/Decline
      // directly on the order card, keyed by the SAME orderId the event
      // carries (this is what keeps the order id correct end-to-end).
      // event.reference is an OrderChangesRequest (from order_event.dart),
      // a different class than OrderModel's ChangesRequestModel — so we
      // map the fields across rather than assuming they're the same type.
      if (event.eventType == OrderEventType.orderChangeRequest) {
        final ref = event.reference;
        if (ref != null) {
          final mapped = ChangesRequestModel(
            id: ref.id ?? 0,
            changesType: ref.changesType,
            requestType: ref.changesType,
            status: 'PENDING',
            message: ref.message,
            proposedDate: ref.proposedDate,
            proposedTime: ref.proposedTime,
            proposedBudget: ref.proposedBudget,
            proposedHour: ref.proposedHour,
            sender: event.sender,
          );
          if (mapped.isTimeChange) {
            _liveTimeChangeRequests[orderId] = mapped;
            allOrders.refresh();
          }
        }
      }

      _reloadOrdersWithDedup();
    });
  }

  Future<void> _reloadOrdersWithDedup() async {
    isLoading.value = true;
    try {
      final freshOrders = await _orderRepo.getCustomerOrders();
      final existingIds = allOrders.map((o) => o.id).toSet();
      final newOrders = <OrderModel>[];

      for (final order in freshOrders) {
        if (existingIds.contains(order.id)) {
          final index = allOrders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            allOrders[index] = order;
          } else {
            newOrders.add(order);
          }
        } else {
          newOrders.add(order);
        }
      }

      if (newOrders.isNotEmpty) {
        allOrders.addAll(newOrders);
      }

      _orderIds.clear();
      _orderIds.addAll(allOrders.map((o) => o.id));
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final freshOrders = await _orderRepo.getCustomerOrders();
      allOrders.value = freshOrders;
      _orderIds.clear();
      _orderIds.addAll(freshOrders.map((o) => o.id));
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrderDetail(int id) async {
    isDetailLoading.value = true;
    try {
      final detail = await _orderRepo.getCustomerOrderDetail(id);
      selectedOrder.value = detail;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {}
    finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> acceptOrder(int id) async {
    try {
      await _orderRepo.acceptOrder(id);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  /// ✅ Client sends counter offer back to provider.
  Future<void> sendCounterOffer(
      int id, double budget, String message) async {
    try {
      await _orderRepo.sendCounterOffer(id, budget, message);
      // Mark immediately so Counter button hides right away
      _clientCounterSentIds.add(id);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Failed to send counter offer.'.tr);
    }
  }

  Future<void> cancelOrder(int id, String message) async {
    try {
      await _orderRepo.cancelOrder(id, message);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> payAndConfirm(int id) async {
    try {
      await _orderRepo.payAndConfirm(id);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> giveFeedback(int id, int rating, String review) async {
    try {
      await _orderRepo.giveFeedback(id, rating, review);
      ReviewedOrders.mark(id);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> proposeNewTime(
      int id, String date, String time, String message) async {
    try {
      await _orderRepo.customerProposeNewTime(
        id,
        action: 'create',
        date: date,
        time: time,
        message: message,
      );
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> cancelAcceptOrder(
      int orderId, int changesRequestId, String action) async {
    try {
      await _orderRepo.cancelAcceptCustomer(
          orderId, changesRequestId, action);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  /// ✅ NEW: Client responds (Accept/Decline) to a provider's proposed
  /// new time, directly from the order card. Uses the SAME orderId that
  /// was attached to the order this card represents — no separate
  /// screen, no risk of mismatched order ids.
  Future<void> respondToTimeChange(int orderId, String action) async {
    final req = pendingTimeChangeFor(orderId);
    if (req == null || req.id == 0) {
      Get.snackbar('Error'.tr, 'Request reference missing. Pull to refresh and try again.'.tr);
      return;
    }
    try {
      final apiStatus = action.toUpperCase() == 'ACCEPT' ? 'accept' : 'decline';
      await _orderRepo.customerProposeNewTime(
        orderId,
        action: 'update',
        requestId: req.id,
        status: apiStatus,
      );
      _liveTimeChangeRequests.remove(orderId);
      await _reloadOrdersWithDedup();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Failed to respond. Please try again.'.tr);
    }
  }
}
