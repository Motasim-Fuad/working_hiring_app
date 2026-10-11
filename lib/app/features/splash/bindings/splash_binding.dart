import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/data/repositories/auth_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.put(SplashController(Get.find(), Get.find()));
  }
}
