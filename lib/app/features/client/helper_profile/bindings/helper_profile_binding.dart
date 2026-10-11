import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';

class HelperProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<HelperRepository>(
      () => HelperRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HelperDetailController>(
      () => HelperDetailController(Get.find()),
    );
  }
}
