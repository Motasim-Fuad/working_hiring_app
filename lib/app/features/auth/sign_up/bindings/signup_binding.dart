import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/auth_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/auth/sign_up/controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController(Get.find()));
  }
}
