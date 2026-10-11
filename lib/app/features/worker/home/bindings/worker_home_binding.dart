import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';

class WorkerHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AvailabilityRepository>(
      () => AvailabilityRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<WorkerHomeController>(
      () => WorkerHomeController(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
  }
}
