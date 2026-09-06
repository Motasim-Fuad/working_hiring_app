import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:working_hiring/app/service/websocket_service.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/repositories/availability_repository.dart';
import '../../../../../app/data/models/order_model.dart';
import '../../../../../app/data/models/availability_model.dart';
import '../../../../../app/data/models/order_event.dart';
import '../../../../../app/service/api_service.dart';
import '../../../../../app/service/order_event_bus.dart';
import '../../../../../app/service/reviewed_orders.dart';
import '../../../../../app/service/notification_dispatcher.dart';
import '../../../message/controllers/message_controller.dart';

class MyJobController extends GetxController {
  final OrderRepository _orderRepo;
  final AvailabilityRepository _availabilityRepo;

  MyJobController(this._orderRepo, this._availabilityRepo);

  final RxList<OrderModel> pendingJobs = <OrderModel>[].obs;
  final RxList<OrderModel> acceptedJobs = <OrderModel>[].obs;
  final RxList<OrderModel> completedJobs = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<OrderEvent>? _busSub;
  VoidCallback? _notifyUnsub;

  /// Session-based counter tracking for provider (used to hide Counter button).
  final Set<int> _counterSentIds = {};

  /// ✅ Track client counters based on order_change_action from API.
  final Set<int> _clientCounteredIds = {};

  bool hasCountered(int orderId) {
    if (_counterSentIds.contains(orderId)) return true;
    final allJobs = [...pendingJobs, ...acceptedJobs, ...completedJobs];
    final job = allJobs.where((j) => j.id == orderId).firstOrNull;
    final action = (job?.orderChangeAction ?? '').toUpperCase();
    if (action == 'PROVIDER_COUNTER_SEND' ||
        action == 'CUSTOMER_COUNTER_SEND') {
      return true;
    }
    return job?.providerAlreadyCountered ?? false;
  }

  bool hasClientCountered(int orderId) {
    debugPrint('[MyJob] hasClientCountered($orderId): _clientCounteredIds=$_clientCounteredIds');
    if (_clientCounteredIds.contains(orderId)) {
      debugPrint('[MyJob] ✅ Client counter found in session set for order $orderId');
      return true;
    }
    // Fallback: check orderChangeAction if not in set (should not happen after loadJobs)
    final allJobs = [...pendingJobs, ...acceptedJobs, ...completedJobs];
    final job = allJobs.where((j) => j.id == orderId).firstOrNull;
    if (job?.orderChangeAction == 'CUSTOMER_COUNTER_SEND') return true;
    return false;
  }

  /// Session-based "Propose New Time" tracking.
  final Set<int> _proposeTimeSentIds = {};

  bool hasProposedTime(int orderId) => _proposeTimeSentIds.contains(orderId);

  void _resetProposeTimeFlagIfStale(List<OrderModel> orders) {
    final activeIds = orders
        .where((o) => o.status == 'CONFIRM')
        .map((o) => o.id)
        .toSet();
    _proposeTimeSentIds.removeWhere((id) => !activeIds.contains(id));
  }

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    _subscribeToBus();
    _subscribeToNotifications();
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
      final orderId = event.order?.id;
      if (orderId == null) return;

      if (event.eventType == OrderEventType.orderCounter) {
        final sender = (event.sender ?? '').toUpperCase().trim();
        debugPrint('[MyJob] ORDER_COUNTER via bus: sender=$sender, orderId=$orderId');
        if (sender == 'CUSTOMER') {
          _clientCounteredIds.add(orderId);
          debugPrint('[MyJob] ✅ Client counter added (bus) for order $orderId');
          pendingJobs.refresh();
          acceptedJobs.refresh();
          completedJobs.refresh();
        }
      }
      loadJobs();
    });
  }

  /// Listen to notifications – reload orders to pick up updated order_change_action.
  void _subscribeToNotifications() {
    _notifyUnsub = NotificationDispatcher.instance.addListener((data) {
      final entityType = (data['entity_type'] as String?)?.toLowerCase();
      if (entityType == 'order') {
        loadJobs();
      }
    });
  }

  Future<void> loadJobs() async {
    isLoading.value = true;
    try {
      final orders = await _orderRepo.getProviderOrders();
      pendingJobs.value =
          orders.where((o) => o.effectiveStatus == 'PENDING').toList();
      acceptedJobs.value = orders
          .where((o) =>
          o.effectiveStatus == 'ACCEPT' ||
          o.effectiveStatus == 'CONFIRM' ||
          o.effectiveStatus == 'CANCELLATION_REQUEST' ||
          o.effectiveStatus == 'IN_PROGRESS')
          .toList();
      completedJobs.value =
          orders.where((o) => o.effectiveStatus == 'COMPLETED').toList();

      // ✅ Update client counter flags using order_change_action
      _clientCounteredIds.clear();
      for (final job in pendingJobs) {
        if (job.orderChangeAction == 'CUSTOMER_COUNTER_SEND') {
          _clientCounteredIds.add(job.id);
        }
      }

      // Clean up stale provider counter flags (only for PENDING orders we care about)
      final pendingIds = pendingJobs.map((o) => o.id).toSet();
      _counterSentIds.removeWhere((id) => !pendingIds.contains(id));

      _resetProposeTimeFlagIfStale(orders);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  // ── Accept ─────────────────────────────────────────────────────────────
  Future<void> acceptJob(int id) async {
    try {
      await _orderRepo.acceptProviderOrder(id);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  // ── Counter offer ──────────────────────────────────────────────────────
  Future<void> sendCounterOffer(
      int id, double budget, String message) async {
    try {
      await _orderRepo.sendProviderCounterOffer(id, budget, message);
      _counterSentIds.add(id);
      await loadJobs();
      if (Get.isRegistered<MessageController>()) {
        await Get.find<MessageController>().reloadChatsForOrder(
          id,
          budget: budget,
          message: message,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Failed to send counter offer.'.tr);
    }
  }

  // ── Decline ────────────────────────────────────────────────────────────
  Future<void> declineJob(int id, String reason) async {
    try {
      await _orderRepo.cancelProviderOrder(id, reason);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  // ── Cancel (after acceptance) ──────────────────────────────────────────
  Future<void> cancelJob(int id, String message) async {
    try {
      await _orderRepo.cancelProviderOrder(id, message);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  // ── Start work ─────────────────────────────────────────────────────────
  Future<void> startWork(int id) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) return;
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final address = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Current Location';

      final message = await _orderRepo.startWork(
        id,
        address,
        position.latitude,
        position.longitude,
      );

      await loadJobs();

    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ── Complete work ──────────────────────────────────────────────────────
  Future<bool> completeWork(int jobId, String otp) async {
    try {
      await _orderRepo.completeWork(jobId, otp);
      await loadJobs();
      return true;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return false;
    }
  }

  // ── Feedback ───────────────────────────────────────────────────────────
  Future<void> giveFeedback(int id, int rating, String review) async {
    try {
      await _orderRepo.giveProviderFeedback(id, rating, review);
      ReviewedOrders.mark(id);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  // ── Set work hours ─────────────────────────────────────────────────────
  Future<void> setWorkHour(int id, int hours, {String? message}) async {
    try {
      await _orderRepo.setWorkHour(id, hours, message: message);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  // ── Propose new time: available slots ──────────────────────────────────
  Future<List<DateSlot>> fetchAvailableSlots(DateTime date) async {
    try {
      final all = await _availabilityRepo.getDateSlotList(
        date,
        profileType: 'provider',
      );
      return all.where((s) => s.isAvailable).toList();
    } catch (e) {
      debugPrint('[MyJob][ProposeTime] fetchAvailableSlots error: $e');
      return [];
    }
  }

  // ── Propose new time: submit ────────────────────────────────────────────
  Future<void> proposeNewTime(
      int id, String date, String time, String message) async {
    try {
      await _orderRepo.providerProposeNewTime(
        id,
        action: 'create',
        date: date,
        time: time,
        message: message,
      );
      _proposeTimeSentIds.add(id);
      await loadJobs();
    } on ApiException catch (e) {
      final isAvailabilityError =
          e.message.toLowerCase().contains('unavailable') ||
              e.message.toLowerCase().contains('unavailasble');
      Get.snackbar(
        isAvailabilityError ? 'Availability Off' : 'Cannot Propose Time',
        isAvailabilityError
            ? 'Your availability is currently set to OFF.\n'
            'Go to Profile → turn ON your availability, then try again.'
            : e.message,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 7),
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } catch (_) {
      Get.snackbar('Error'.tr, 'Failed to propose new time. Please try again.'.tr);
    }
  }

  // ── Respond to cancellation request ───────────────────────────────────
  Future<void> cancelAcceptJob(
      int orderId, int changesRequestId, String action) async {
    try {
      await _orderRepo.cancelAcceptProvider(
          orderId, changesRequestId, action);
      await loadJobs();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }
}
