import 'package:get/get.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/repositories/chat_repository.dart';
import '../../../../../app/data/repositories/availability_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../create_task/controllers/create_task_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../../message/controllers/message_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperRepository>(() => HelperRepository(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()), fenix: true);
    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find()), fenix: true);
    // ✅ NEW: needed by MessageController for "Propose New Time"'s real
    // available-slot picker in ChatView (same repo MyJobController uses).
    Get.lazyPut<AvailabilityRepository>(() => AvailabilityRepository(Get.find()), fenix: true);
    Get.lazyPut<MessageController>(() => MessageController(Get.find<ChatRepository>(), Get.find<OrderRepository>(), Get.find<AvailabilityRepository>()), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(Get.find(), Get.find(), Get.find(), Get.find()), fenix: true);
    Get.lazyPut<CreateTaskController>(() => CreateTaskController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(Get.find()), fenix: true);
  }
}