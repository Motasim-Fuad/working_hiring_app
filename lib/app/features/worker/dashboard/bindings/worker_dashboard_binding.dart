import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';
import 'package:working_hiring/app/features/worker/dashboard/controllers/worker_dashboard_controller.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AvailabilityRepository>(
      () => AvailabilityRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HelperRepository>(
      () => HelperRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find()),
      fenix: true,
    );

    Get.lazyPut<WorkerDashboardController>(
      () => WorkerDashboardController(),
      fenix: true,
    );
    Get.lazyPut<WorkerHomeController>(
      () => WorkerHomeController(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<MyJobController>(
      () => MyJobController(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find()), fenix: true);
    Get.lazyPut<MessageController>(
      () => MessageController(
        Get.find<ChatRepository>(),
        Get.find<OrderRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find()),
      fenix: true,
    );

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
