import 'package:get/get.dart';
import '../../../service/shared_prefs_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../i_want_to_work/dashboard/bindings/worker_dashboard_binding.dart';
import '../../i_want_to_work/dashboard/controllers/worker_dashboard_controller.dart';
import '../../i_need_help/dashboard/bindings/dashboard_binding.dart';
import '../../../routes/app_pages.dart';

class MainController extends GetxController {
  // 1 = CUSTOMER (I Need Help), 2 = PROVIDER (I Want to Work)
  final RxInt activePhase = 1.obs;
  final RxBool isReady = false.obs;
  bool _customerInit = false;
  bool _providerInit = false;
  bool _handledInitialAction = false;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  @override
  void onReady() {
    super.onReady();
    _handleInitialAction();
  }

  void _handleInitialAction() {
    if (_handledInitialAction) return;
    final arguments = Get.arguments;
    final shouldOpenCreateProfile = arguments is Map &&
        arguments['openCreateProfile'] == true;
    if (!shouldOpenCreateProfile) return;

    _handledInitialAction = true;
    Future.microtask(() {
      if (Get.currentRoute == Routes.MAIN) {
        Get.toNamed(Routes.CREATE_HELPER_PROFILE);
      }
    });
  }

  Future<void> _loadProfile() async {
    final profile =
        await SharedPrefsHelper.getString(AppConstants.defaultProfile);
    if (profile == 'PROVIDER') {
      activePhase.value = 2;
      _initProviderDashboard();
    } else {
      activePhase.value = 1;
      _initCustomerDashboard();
    }
    isReady.value = true;
    update(['main-phase']);
  }

  void _initCustomerDashboard() {
    if (_customerInit) return;
    DashboardBinding().dependencies();
    _customerInit = true;
  }

  void _initProviderDashboard() {
    if (_providerInit) return;
    WorkerDashboardBinding().dependencies();
    _providerInit = true;
  }

  void changePhase(int phaseIndex) {
    if (phaseIndex != 1 && phaseIndex != 2) return;

    if (activePhase.value != phaseIndex) {
      activePhase.value = phaseIndex;
      final profile = phaseIndex == 2 ? 'PROVIDER' : 'CUSTOMER';
      SharedPrefsHelper.setString(AppConstants.defaultProfile, profile);
    }

    if (phaseIndex == 2) {
      _initProviderDashboard();
      if (Get.isRegistered<WorkerDashboardController>()) {
        Get.find<WorkerDashboardController>().refreshAccess();
      }
    } else {
      _initCustomerDashboard();
    }

    // Explicitly rebuild MainView as well as notifying reactive listeners.
    // This protects role switching after route/controller lifecycle changes.
    update(['main-phase']);
  }
}
