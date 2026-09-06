import 'package:get/get.dart';
import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/create_task_controller.dart';

class CreateTaskBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()), fenix: true);
    Get.lazyPut<CreateTaskController>(() => CreateTaskController(Get.find(), Get.find()), fenix: true);
  }
}
