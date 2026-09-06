import 'package:get/get.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../my_job/controllers/my_job_controller.dart';
import '../../../message/controllers/message_controller.dart';

enum ProviderAccessState {
  loading,
  noProfile,
  unverified,
  verified,
  error,
}

class WorkerDashboardController extends GetxController {
  final RxInt tabIndex = 0.obs;
  final Rx<ProviderAccessState> accessState =
      ProviderAccessState.loading.obs;
  final RxString accessError = ''.obs;
  int _accessRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    refreshAccess();
    if (Get.arguments != null && Get.arguments is Map) {
      if (Get.arguments['initialIndex'] != null) {
        tabIndex.value = Get.arguments['initialIndex'];
      }
    }
  }

  bool _isMissingProfileError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('no service_provider_profile') ||
        message.contains('no service provider profile') ||
        message.contains('no provider profile') ||
        message.contains('helper profile not found') ||
        message.contains('helper profile not created') ||
        message.contains('profile not created') ||
        message.contains('profile does not exist');
  }

  /// Resolves provider access in the required order:
  /// profile existence -> verification -> provider dashboard.
  ///
  /// No provider-only dashboard endpoint is touched before this check succeeds.
  Future<void> refreshAccess() async {
    final requestId = ++_accessRequestId;
    accessState.value = ProviderAccessState.loading;
    accessError.value = '';

    try {
      final helperRepo = HelperRepository(Get.find<ApiClient>());
      final profile = await helperRepo.getMyHelperProfile();
      if (requestId != _accessRequestId) return;

      var isVerified = profile['is_verified'] == true;
      if (!isVerified) {
        try {
          final userRepo = UserRepository(Get.find<ApiClient>());
          final verification =
              await userRepo.getVerificationStatus(profileType: 'provider');
          isVerified = verification != null &&
              verification['is_verified'] == true &&
              verification['status'] == 'APPROVED';
        } catch (_) {
          // A missing verification record means the existing profile still
          // needs verification. It is not a missing-profile state.
        }
      }

      if (requestId != _accessRequestId) return;
      accessState.value = isVerified
          ? ProviderAccessState.verified
          : ProviderAccessState.unverified;
    } on ApiException catch (error) {
      if (requestId != _accessRequestId) return;
      if (_isMissingProfileError(error)) {
        accessState.value = ProviderAccessState.noProfile;
      } else {
        accessError.value = error.message;
        accessState.value = ProviderAccessState.error;
      }
    } catch (error) {
      if (requestId != _accessRequestId) return;
      if (_isMissingProfileError(error)) {
        accessState.value = ProviderAccessState.noProfile;
      } else {
        accessError.value = error.toString();
        accessState.value = ProviderAccessState.error;
      }
    }
  }

  Future<void> openCreateProfile() async {
    await Get.toNamed(Routes.CREATE_HELPER_PROFILE);
    await refreshAccess();
  }

  Future<void> openVerification() async {
    await Get.toNamed(Routes.WORKER_ACCOUNT_VERIFICATION);
    await refreshAccess();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
    // Refresh data whenever the user switches to My Jobs (1) or Messages (2)
    // so they always see up-to-date requests without restarting the app.
    if (index == 1 && Get.isRegistered<MyJobController>()) {
      Get.find<MyJobController>().loadJobs();
    } else if (index == 2 && Get.isRegistered<MessageController>()) {
      Get.find<MessageController>().loadRooms();
    }
  }
}
