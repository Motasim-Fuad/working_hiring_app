import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/notification_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/notification/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find()),
      fenix: true,
    );
  }
}
