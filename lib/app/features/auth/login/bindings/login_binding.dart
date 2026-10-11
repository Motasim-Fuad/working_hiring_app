import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/auth_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/auth/login/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
  }
}
