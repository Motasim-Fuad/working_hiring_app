import 'package:get/get.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../service/api_service.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<NotificationRepository>(() => NotificationRepository(Get.find()), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(Get.find()), fenix: true);
  }
}
