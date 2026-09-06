import 'package:get/get.dart';
import '../../../../../app/data/repositories/order_repository.dart';
import '../../../../../app/data/repositories/availability_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/my_job_controller.dart';

class MyJobBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()), fenix: true);
    // ✅ NEW: MyJobController now needs AvailabilityRepository to fetch the
    // provider's real available time slots for "Propose New Time" (see
    // MyJobController.fetchAvailableSlots).
    Get.lazyPut<AvailabilityRepository>(() => AvailabilityRepository(Get.find()), fenix: true);
    Get.lazyPut<MyJobController>(() => MyJobController(Get.find(), Get.find()), fenix: true);
  }
}