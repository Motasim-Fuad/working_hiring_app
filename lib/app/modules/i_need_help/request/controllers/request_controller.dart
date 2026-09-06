import 'package:get/get.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../service/api_service.dart';

class RequestController extends GetxController {
  final HelperRepository _helperRepo;

  RequestController(this._helperRepo);

  final RxList<HelperListModel> candidates = <HelperListModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCandidates();
  }

  Future<void> loadCandidates() async {
    isLoading.value = true;
    try {
      final result = await _helperRepo.getHelpers();
      candidates.value = result.helpers;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {}
    isLoading.value = false;
  }

  void onAccept(HelperListModel tasker) {
  }

  void onMessage(HelperListModel tasker) {
  }
}
