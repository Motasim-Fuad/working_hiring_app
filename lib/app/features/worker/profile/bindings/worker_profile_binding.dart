import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperRepository>(
      () => HelperRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AvailabilityRepository>(
      () => AvailabilityRepository(Get.find()),
      fenix: true,
    );

    Get.lazyPut<HelperProfileController>(
      () => HelperProfileController(
        Get.find<HelperRepository>(),
        Get.find<CategoryRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<WorkerProfileController>(
      () => WorkerProfileController(
        Get.find<UserRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
      fenix: true,
    );
  }
}
