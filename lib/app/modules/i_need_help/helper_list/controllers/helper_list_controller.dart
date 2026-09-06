// lib/modules/i_need_help/helper_list/controllers/helper_list_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/helper_model.dart';
import '../../../../data/models/saved_helper_model.dart';
import '../../../../service/api_service.dart';
import '../../../../routes/app_pages.dart';

class HelperListController extends GetxController {
  final HelperRepository _helperRepo;
  final CategoryRepository _categoryRepo;

  HelperListController(this._helperRepo, this._categoryRepo);

  final categoryName = 'Helpers'.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();

  final allHelpers = <HelperListModel>[].obs;
  final displayedHelpers = <HelperListModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  String? _nextUrl;

  final maxDistance = 50.0.obs;
  final minRating = 1.0.obs;
  final selectedCategoryFilter = 'All Categories'.obs;
  final selectedCategoryId = Rxn<int>();

  final tempMaxDistance = 50.0.obs;
  final tempMinRating = 1.0.obs;
  final tempSelectedCategoryFilter = 'All Categories'.obs;

  final selectedSort = 'Distance (Nearest)'.obs;

  final Rxn<DateTime> tempSelectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> tempSelectedTime = Rxn<TimeOfDay>();
  final tempLocation = ''.obs;
  final tempMinBudget = 10.0.obs;
  final tempMaxBudget = 200.0.obs;
  final tempShowAvailableOnly = false.obs;

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final location = ''.obs;
  final minBudget = 10.0.obs;
  final maxBudget = 200.0.obs;
  final showAvailableOnly = false.obs;

  final availableCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  final Rxn<DateTime> requestedDate = Rxn<DateTime>();

  Timer? _searchTimer;

  // ---------- Saved Helpers ----------
  final RxMap<int, int> savedHelperMap = <int, int>{}.obs; // helperId -> entryId
  final RxList<SavedHelperEntry> savedHelpers = <SavedHelperEntry>[].obs;
  final RxBool isLoadingSaved = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final args = Get.arguments as Map;
        final argCategory = args['category']?.toString();
        if (argCategory != null && argCategory.isNotEmpty) {
          categoryName.value = argCategory;
          selectedCategoryFilter.value = argCategory;
          tempSelectedCategoryFilter.value = argCategory;
        }
        final argDate = args['date'];
        if (argDate != null && argDate is DateTime) {
          requestedDate.value = argDate;
        }
        final argQuery = args['query']?.toString();
        if (argQuery != null && argQuery.isNotEmpty) {
          searchQuery.value = argQuery;
          searchTextController.text = argQuery;
        }
      } else {
        categoryName.value = Get.arguments.toString();
        selectedCategoryFilter.value = Get.arguments.toString();
        tempSelectedCategoryFilter.value = Get.arguments.toString();
      }
    }

    _loadCategories().then((_) {
      loadHelpers();
      fetchSavedHelperMap();
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 400), () {
      searchQuery.value = value.trim();
      loadHelpers();
    });
  }

  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final cats = await _categoryRepo.getCategories(profileType: 'customer');
      availableCategories.clear();
      availableCategories.addAll(cats);
      final match = cats.where(
            (c) => c.title?.toLowerCase() == selectedCategoryFilter.value.toLowerCase(),
      );
      if (match.isNotEmpty) {
        selectedCategoryId.value = match.first.id;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> loadHelpers() async {
    isLoading.value = true;
    try {
      int? categoryId = selectedCategoryId.value;
      if (categoryId == null && selectedCategoryFilter.value != 'All Categories') {
        final match = availableCategories.where(
              (c) => c.title?.toLowerCase() == selectedCategoryFilter.value.toLowerCase(),
        );
        if (match.isNotEmpty) categoryId = match.first.id;
      }

      final result = await _helperRepo.getHelpers(
        query: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        categoryId: categoryId,
        distanceRadius: maxDistance.value < 50 ? maxDistance.value : null,
        budget: maxBudget.value < 200 ? maxBudget.value : null,
        rating: minRating.value > 1 ? minRating.value : null,
        availability: showAvailableOnly.value ? true : null,
        sortBy: _mapSortToApi(selectedSort.value),
        profileType: 'customer',
      );

      _nextUrl = result.nextUrl;
      allHelpers.clear();
      allHelpers.addAll(result.helpers);
      displayedHelpers.clear();
      displayedHelpers.addAll(result.helpers);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreHelpers() async {
    if (_nextUrl == null || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _helperRepo.getHelpersFromUrl(_nextUrl!,
          profileType: 'customer');
      _nextUrl = result.nextUrl;
      allHelpers.addAll(result.helpers);
      displayedHelpers.addAll(result.helpers);
    } on ApiException catch (e) {
      // ignore
    } catch (e) {
      // ignore
    } finally {
      isLoadingMore.value = false;
    }
  }

  String? _mapSortToApi(String sort) {
    switch (sort) {
      case 'Rating (High-Low)':
        return 'rating';
      case 'Price (Low-High)':
        return 'price';
      case 'Distance (Nearest)':
        return 'distance';
      default:
        return null;
    }
  }

  void applyFilters({bool isInitial = false}) {
    if (!isInitial) {
      maxDistance.value = tempMaxDistance.value;
      minRating.value = tempMinRating.value;
      selectedCategoryFilter.value = tempSelectedCategoryFilter.value;
      selectedDate.value = tempSelectedDate.value;
      selectedTime.value = tempSelectedTime.value;
      location.value = tempLocation.value;
      minBudget.value = tempMinBudget.value;
      maxBudget.value = tempMaxBudget.value;
      showAvailableOnly.value = tempShowAvailableOnly.value;
    }

    if (selectedCategoryFilter.value != 'All Categories') {
      final match = availableCategories.where(
            (c) => c.title?.toLowerCase() == selectedCategoryFilter.value.toLowerCase(),
      );
      selectedCategoryId.value = match.isNotEmpty ? match.first.id : null;
    } else {
      selectedCategoryId.value = null;
    }

    loadHelpers();

    if (!isInitial) {
      Get.back();
    }
  }

  void applySort() {
    if (selectedSort.value == 'Rating (High-Low)') {
      displayedHelpers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (selectedSort.value == 'Price (Low-High)') {
      displayedHelpers.sort((a, b) => (a.hourlyRate ?? 0).compareTo(b.hourlyRate ?? 0));
    } else if (selectedSort.value == 'Distance (Nearest)') {
      displayedHelpers.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    }
    displayedHelpers.refresh();
  }

  void clearFilters() {
    maxDistance.value = 50.0;
    minRating.value = 1.0;
    selectedCategoryFilter.value = 'All Categories';
    selectedCategoryId.value = null;
    selectedDate.value = null;
    selectedTime.value = null;
    location.value = '';
    minBudget.value = 10.0;
    maxBudget.value = 200.0;
    showAvailableOnly.value = false;

    tempMaxDistance.value = 50.0;
    tempMinRating.value = 1.0;
    tempSelectedCategoryFilter.value = 'All Categories';
    tempSelectedDate.value = null;
    tempSelectedTime.value = null;
    tempLocation.value = '';
    tempMinBudget.value = 10.0;
    tempMaxBudget.value = 200.0;
    tempShowAvailableOnly.value = false;

    loadHelpers();
    Get.back();
  }

  void navigateToProfile(HelperListModel helper) {
    Get.toNamed(Routes.HELPER_PROFILE, arguments: helper);
  }

  // ---------- Saved Helpers ----------

  Future<void> fetchSavedHelperMap() async {
    try {
      final saved = await _helperRepo.getSavedHelpers(profileType: 'customer');
      savedHelperMap.clear();
      for (var entry in saved) {
        savedHelperMap[entry.helper.id] = entry.entryId;
      }
    } catch (e) {
      debugPrint('fetchSavedHelperMap error: $e');
    }
  }

  Future<void> loadSavedHelpers() async {
    isLoadingSaved.value = true;
    try {
      final saved = await _helperRepo.getSavedHelpers(profileType: 'customer');
      savedHelpers.assignAll(saved);
      // Also update map
      savedHelperMap.clear();
      for (var entry in saved) {
        savedHelperMap[entry.helper.id] = entry.entryId;
      }
    } catch (e) {
      debugPrint('loadSavedHelpers error: $e');
      Get.snackbar('Error'.tr, 'Could not load saved helpers.'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingSaved.value = false;
    }
  }

  Future<void> toggleSaveHelper(HelperListModel helper) async {
    final isSaved = savedHelperMap.containsKey(helper.id);
    try {
      if (isSaved) {
        final entryId = savedHelperMap[helper.id]!;
        await _helperRepo.removeSavedHelper(entryId, profileType: 'customer');
        savedHelperMap.remove(helper.id);
        // Also update savedHelpers list if it contains this entry
        savedHelpers.removeWhere((e) => e.helper.id == helper.id);
      } else {
        await _helperRepo.saveHelper(helper.id, profileType: 'customer');
        // refresh map to get new entry id
        await fetchSavedHelperMap();
        // also refresh savedHelpers list if open
        await loadSavedHelpers();
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not save/unsave helper.'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }
}