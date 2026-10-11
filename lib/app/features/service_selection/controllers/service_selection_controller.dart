import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/data/models/category_model.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/routes/app_pages.dart';

class ServiceSelectionController extends GetxController {
  final CategoryRepository _categoryRepo;

  ServiceSelectionController(this._categoryRepo);

  final RxList<CategoryModel> services = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<int> selectedServiceIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final categories = await _categoryRepo.getCategories();
      services.clear();
      services.addAll(categories);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(int id) {
    if (selectedServiceIds.contains(id)) {
      selectedServiceIds.remove(id);
    } else {
      selectedServiceIds.add(id);
    }
  }

  void onDone() {
    if (selectedServiceIds.isEmpty) return;
    Get.toNamed(Routes.CREATE_HELPER_PROFILE);
  }

  void onSkip() {
    Get.offAllNamed(Routes.MAIN);
  }
}
