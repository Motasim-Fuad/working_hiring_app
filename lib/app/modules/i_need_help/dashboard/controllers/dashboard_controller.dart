import 'package:get/get.dart';

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      tabIndex.value = Get.arguments['index'] ?? 0;
    }
  }

  void changeTabIndex(int index) {
    if (tabIndex.value == index) return;

    // Fix Focus: Unfocus any active input
    Get.focusScope?.unfocus();

    // Fix Overlay: Close any open dialogs or snackbars
    if (Get.isDialogOpen == true) Get.back();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    tabIndex.value = index;
  }
}
