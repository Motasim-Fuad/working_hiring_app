import 'package:get/get.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/data/repositories/category_repository.dart';
import '../../../../../app/data/repositories/availability_repository.dart'; // <-- add this
import '../../../../../app/service/api_service.dart';
import '../controllers/worker_profile_controller.dart';
import '../helper_profile_controller.dart';

class WorkerProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperRepository>(() => HelperRepository(Get.find()), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);
    Get.lazyPut<AvailabilityRepository>(() => AvailabilityRepository(Get.find()), fenix: true); // <-- added

    // Inject both repositories into HelperProfileController
    Get.lazyPut<HelperProfileController>(
          () => HelperProfileController(
        Get.find<HelperRepository>(),
        Get.find<CategoryRepository>(),
      ),
      fenix: true,
    );

    // ✅ Pass both repositories to WorkerProfileController
    Get.lazyPut<WorkerProfileController>(
          () => WorkerProfileController(
        Get.find<UserRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );
  }
}