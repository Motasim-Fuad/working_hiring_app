import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/service_selection/controllers/service_selection_controller.dart';

class ServiceSelectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find()),
      fenix: true,
    );
    Get.put(ServiceSelectionController(Get.find()));
  }
}
