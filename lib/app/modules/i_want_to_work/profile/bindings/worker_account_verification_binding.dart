import 'package:get/get.dart';
import '../../../../../app/data/repositories/user_repository.dart';
import '../../../../../app/service/api_service.dart';
import '../controllers/worker_account_verification_controller.dart';

class WorkerAccountVerificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<WorkerAccountVerificationController>(
      () => WorkerAccountVerificationController(Get.find()),
    );
  }
}
