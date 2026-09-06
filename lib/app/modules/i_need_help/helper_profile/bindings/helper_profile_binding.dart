import 'package:get/get.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/helper_profile_controller.dart';

class HelperProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<HelperRepository>(() => HelperRepository(Get.find()), fenix: true);
    Get.lazyPut<HelperDetailController>(() => HelperDetailController(Get.find()));
  }
}
