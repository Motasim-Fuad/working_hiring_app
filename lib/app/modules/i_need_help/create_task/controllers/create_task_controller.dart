import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/order_event.dart';
import '../../../../service/api_service.dart';
import '../../../../service/order_event_bus.dart';

class CreateTaskController extends GetxController {
  final OrderRepository _orderRepo;
  final CategoryRepository _categoryRepo;

  final taskTitleController = TextEditingController();
  final addressController = TextEditingController();
  final detailsController = TextEditingController();
  final budgetController = TextEditingController();

  final RxString selectedCategory = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxString selectedSubCategory = ''.obs;
  final RxInt selectedCategoryId = 0.obs;
  final RxInt selectedSubCategoryId = 0.obs;

  /// Estimated job hours — sent to backend as `working_hour` (spec §7.2).
  final RxInt workingHour = 1.obs;

  // ✅ নতুন: map থেকে নেওয়া আসল location (default 0.0)
  final RxDouble selectedLat = 0.0.obs;
  final RxDouble selectedLng = 0.0.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isSubmitting = false.obs;

  List<SubCategoryModel> get subCategories {
    if (selectedCategoryId.value == 0) return [];
    final cat = categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
    return cat?.subcategories ?? [];
  }

  bool isEdit = false;

  CreateTaskController(this._orderRepo, this._categoryRepo);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['isEdit'] == true && args['order'] != null) {
        isEdit = true;
        _populateFields(args['order']);
      }
      if (args['category'] != null && args['category'] != '') {
        selectedCategory.value = args['category'];
      }
    }
  }

  /// ✅ নতুন: MapPickerView থেকে আসল lat/lng পেলে এটা call করো।
  void setSelectedLocation(double lat, double lng, {String? addressText}) {
    selectedLat.value = lat;
    selectedLng.value = lng;
    if (addressText != null && addressText.isNotEmpty) {
      addressController.text = addressText;
    }
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      categories.value = await _categoryRepo.getCategories();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {}
    isLoadingCategories.value = false;
  }

  void _populateFields(dynamic order) {
    try {
      taskTitleController.text = order.title ?? '';
      detailsController.text = order.description ?? '';
      budgetController.text = order.amount?.toString() ?? '';
      selectedCategory.value = order.categoryName ?? '';
      addressController.text = order.address ?? '';
    } catch (e) {
      debugPrint("Error populating fields: $e");
    }
  }

  void selectCategory(String categoryName, int categoryId) {
    selectedCategory.value = categoryName;
    selectedCategoryId.value = categoryId;
    selectedSubCategory.value = '';
    selectedSubCategoryId.value = 0;
    Get.back();
  }

  void selectSubCategory(String subCat, int subCatId) {
    selectedSubCategory.value = subCat;
    selectedSubCategoryId.value = subCatId;
    Get.back();
  }

  Future<void> onPostTask() async {
    if (taskTitleController.text.trim().isEmpty) {
      Get.snackbar("Validation".tr, "Please enter a task title".tr);
      return;
    }
    if (selectedCategoryId.value == 0) {
      Get.snackbar("Validation".tr, "Please select a category".tr);
      return;
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar("Validation".tr, "Please enter an address".tr);
      return;
    }

    isSubmitting.value = true;
    try {
      final amount = double.tryParse(budgetController.text.trim()) ?? 0;
      final payload = <String, dynamic>{
        'title': taskTitleController.text.trim(),
        'description': detailsController.text.trim(),
        'category': selectedCategoryId.value,
        'sub_category': selectedSubCategoryId.value,
        // Spec §2.2: DecimalField must be sent as a string.
        'amount': amount.toStringAsFixed(2),
        // Spec §7.2: working_hour is required.
        'working_hour': workingHour.value,
        'area': addressController.text.trim(),
        'lat': selectedLat.value, // ✅ আসল lat (আগে hardcode 0.0 ছিল)
        'lng': selectedLng.value, // ✅ আসল lng (আগে hardcode 0.0 ছিল)
      };

      if (selectedDate.value != null) {
        payload['working_date'] =
        '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';
      }
      if (selectedTime.value != null) {
        final t = selectedTime.value!;
        payload['working_start_time'] =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      }

      final created = await _orderRepo.createOrder(payload);

      // The server fires ORDER_CREATED over the chat WS — but the client
      // isn't subscribed to the brand-new room yet, so that frame is lost
      // (spec §8). Emit a synthetic event so the customer's Order list
      // refreshes without waiting for a manual reload.
      if (Get.isRegistered<OrderEventBus>()) {
        Get.find<OrderEventBus>().emit(OrderEvent(
          id: 0,
          eventType: OrderEventType.orderCreated,
          order: OrderSnapshot(
            id: created.id,
            title: created.title,
            amount: created.amount,
            status: created.status,
            paymentStatus: created.paymentStatus,
            workingDate: created.workingDate,
            workingStartTime: created.workingStartTime,
            workingHour: created.workingHour,
            createdAt: created.createdAt,
          ),
        ));
      }

      if (isEdit) {
        Get.back();
      } else {
        Get.offNamed('/helper-list', arguments: {
          'category': selectedCategory.value,
          'date': selectedDate.value,
        });
      }
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Could not create task. Please try again.".tr);
    }
    isSubmitting.value = false;
  }

  @override
  void onClose() {
    taskTitleController.dispose();
    addressController.dispose();
    detailsController.dispose();
    budgetController.dispose();
    super.onClose();
  }
}