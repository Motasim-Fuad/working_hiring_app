import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../main/controllers/main_controller.dart';

class AboutController extends GetxController {
  final RxBool isWorker = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<MainController>()) {
      // Phase 2 is Worker (I Want to Work)
      isWorker.value = Get.find<MainController>().activePhase.value == 2;
    }
  }

  String get aboutTitle => AppStrings.about.tr;

  String get aboutDescription {
    if (isWorker.value) {
      return AppStrings.iWantToWorkDesc.tr;
    } else {
      return AppStrings.iNeedHelpDesc.tr;
    }
  }
}
