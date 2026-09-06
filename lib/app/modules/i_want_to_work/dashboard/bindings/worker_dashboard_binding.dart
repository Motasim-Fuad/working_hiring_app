import 'package:get/get.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/repositories/availability_repository.dart';
import '../../../../../app/data/repositories/chat_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../../../i_need_help/profile/controllers/profile_controller.dart';
import '../controllers/worker_dashboard_controller.dart';
import '../../home/controllers/worker_home_controller.dart';
import '../../my_job/controllers/my_job_controller.dart';
import '../../../message/controllers/message_controller.dart';
import '../../profile/controllers/worker_profile_controller.dart';
import '../../profile/helper_profile_controller.dart';

class WorkerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()), fenix: true);
    Get.lazyPut<AvailabilityRepository>(() => AvailabilityRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperRepository>(() => HelperRepository(Get.find()), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);

    Get.lazyPut<WorkerDashboardController>(() => WorkerDashboardController(), fenix: true);
    Get.lazyPut<WorkerHomeController>(() => WorkerHomeController(Get.find(), Get.find(), Get.find()), fenix: true);
    Get.lazyPut<MyJobController>(() => MyJobController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find()), fenix: true);
    Get.lazyPut<MessageController>(
          () => MessageController(
        Get.find<ChatRepository>(),
        Get.find<OrderRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()), fenix: true);

    // ✅ Pass both repositories to WorkerProfileController
    Get.lazyPut<WorkerProfileController>(
          () => WorkerProfileController(
        Get.find<UserRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HelperProfileController>(
          () => HelperProfileController(
        Get.find<HelperRepository>(),
        Get.find<CategoryRepository>(),
      ),
      fenix: true,
    );
  }
}