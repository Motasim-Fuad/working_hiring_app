import 'package:get/get.dart';
import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperRepository>(() => HelperRepository(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()), fenix: true);
    Get.put(HomeController(Get.find(), Get.find(), Get.find(), Get.find()));
  }
}
