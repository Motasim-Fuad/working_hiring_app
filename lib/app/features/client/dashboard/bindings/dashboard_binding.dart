import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/dashboard/controllers/dashboard_controller.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HelperRepository>(
      () => HelperRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find()), fenix: true);
    Get.lazyPut<AvailabilityRepository>(
      () => AvailabilityRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<MessageController>(
      () => MessageController(
        Get.find<ChatRepository>(),
        Get.find<OrderRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find(), Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find()),
      fenix: true,
    );
    Get.lazyPut<OrderController>(
      () => OrderController(Get.find()),
      fenix: true,
    );
  }
}
