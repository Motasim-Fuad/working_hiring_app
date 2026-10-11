import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';

class HelperListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<HelperRepository>(
      () => HelperRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HelperListController>(
      () => HelperListController(Get.find(), Get.find()),
    );
  }
}
