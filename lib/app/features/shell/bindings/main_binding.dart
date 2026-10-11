import 'package:get/get.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
  }
}
