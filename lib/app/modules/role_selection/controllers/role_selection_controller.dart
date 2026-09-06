import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../service/shared_prefs_helper.dart';

class RoleSelectionController extends GetxController {
  final _storage = GetStorage();

  Future<void> selectClientRole() async {
    _storage.write('userRole', AppStrings.iNeedHelp);
    await SharedPrefsHelper.setString(
      AppConstants.defaultProfile,
      'CUSTOMER',
    );
    Get.offAllNamed(Routes.MAIN);
  }

  Future<void> selectWorkerRole() async {
    _storage.write('userRole', AppStrings.iWantToWork);
    await SharedPrefsHelper.setString(
      AppConstants.defaultProfile,
      'PROVIDER',
    );

    // Main becomes the stable root route. MainController opens Create Profile
    // after its provider gate is ready, so Back returns to I Want to Work.
    Get.offAllNamed(
      Routes.MAIN,
      arguments: const {'openCreateProfile': true},
    );
  }
}
