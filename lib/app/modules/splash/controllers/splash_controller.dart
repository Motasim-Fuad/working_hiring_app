import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../service/shared_prefs_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final UserRepository _userRepo;
  final AuthRepository _authRepo;

  SplashController(this._userRepo, this._authRepo);

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Get.currentRoute != Routes.SPLASH) return;

    final token = await SharedPrefsHelper.getString(AppConstants.token);

    if (token.isEmpty) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }

    try {
      await _userRepo.getCurrentUser();
      // Provider profile and verification routing is intentionally handled
      // inside WorkerDashboardController. Keeping splash on the main route
      // preserves the role switcher and prevents broken back stacks.
      Get.offAllNamed(Routes.MAIN);
    } catch (_) {
      try {
        final refreshToken =
            await SharedPrefsHelper.getString(AppConstants.refreshToken);
        if (refreshToken.isNotEmpty) {
          final authResp = await _authRepo.refreshToken(refreshToken);
          await SharedPrefsHelper.setString(
              AppConstants.token, authResp.access);
          await SharedPrefsHelper.setString(
              AppConstants.refreshToken, authResp.refresh);
          if (authResp.defaultProfile != null) {
            await SharedPrefsHelper.setString(
                AppConstants.defaultProfile, authResp.defaultProfile!);
          }
          Get.offAllNamed(Routes.MAIN);
          return;
        }
      } catch (_) {
        await SharedPrefsHelper.clearAll();
      }
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }
}
