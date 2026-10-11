import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';

class AboutController extends GetxController {
  final RxBool isWorker = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<MainController>()) {
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
