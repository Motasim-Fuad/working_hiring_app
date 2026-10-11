import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/auth_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/auth/otp_verification/controllers/otp_verification_controller.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.lazyPut<OtpVerificationController>(
      () => OtpVerificationController(Get.find()),
    );
  }
}
