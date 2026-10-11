import 'package:get/get.dart';
import 'package:working_hiring/app/features/role_selection/controllers/role_selection_controller.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RoleSelectionController());
  }
}
