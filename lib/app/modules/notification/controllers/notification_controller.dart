import 'package:get/get.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../service/api_service.dart';
import '../../../service/notification_dispatcher.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notifRepo;

  NotificationController(this._notifRepo);

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  VoidCallback? _notifyUnsub;

  @override
  void onInit() {
    super.onInit();
    loadNotifications(showError: false);
    _notifyUnsub = NotificationDispatcher.instance.addListener((_) {
      loadNotifications(showError: false);
    });
  }

  @override
  void onClose() {
    _notifyUnsub?.call();
    super.onClose();
  }

  Future<void> loadNotifications({bool showError = false}) async {
    final showSpinner = notifications.isEmpty;
    if (showSpinner) isLoading.value = true;
    try {
      notifications.value = await _notifRepo.getNotifications();
    } on ApiException catch (e) {
      if (showError) Get.snackbar("Error", e.message);
    } catch (_) {
      if (showError) {
        Get.snackbar("Error".tr, "Something went wrong.".tr);
      }
    }
    isLoading.value = false;
  }

  Future<void> markRead(int id) async {
    try {
      await _notifRepo.markRead(id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx] = NotificationModel(
          id: notifications[idx].id,
          type: notifications[idx].type,
          title: notifications[idx].title,
          message: notifications[idx].message,
          createdAt: notifications[idx].createdAt,
          isRead: true,
          extraData: notifications[idx].extraData,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Something went wrong.".tr);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _notifRepo.markAllRead();
      notifications.value = notifications
          .map((n) => NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                message: n.message,
                createdAt: n.createdAt,
                isRead: true,
                extraData: n.extraData,
              ))
          .toList();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Something went wrong.".tr);
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _notifRepo.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to delete notification.".tr);
    }
  }
}
