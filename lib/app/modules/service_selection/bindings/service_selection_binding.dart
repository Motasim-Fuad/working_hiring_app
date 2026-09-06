import 'package:get/get.dart';
import '../../../../app/data/repositories/category_repository.dart';
import '../../../../app/service/api_service.dart';
import '../controllers/service_selection_controller.dart';

class ServiceSelectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()), fenix: true);
    Get.put(ServiceSelectionController(Get.find()));
  }
}
