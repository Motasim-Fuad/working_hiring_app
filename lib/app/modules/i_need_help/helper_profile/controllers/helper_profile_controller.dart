import 'package:get/get.dart';

import '../../../../../app/data/models/availability_model.dart';
import '../../../../../app/data/repositories/availability_repository.dart';
import '../../../../../app/data/repositories/helper_repository.dart';
import '../../../../../app/service/api_service.dart';

class HelperDetailController extends GetxController {
  final HelperRepository _helperRepo;

  HelperDetailController(this._helperRepo);

  // Resolved lazily so the existing binding (which only passes
  // HelperRepository) keeps working. Registered in main/app bindings.
  AvailabilityRepository? get _availabilityRepo =>
      Get.isRegistered<AvailabilityRepository>()
          ? Get.find<AvailabilityRepository>()
          : null;

  HelperDetailModel? helper;
  final RxBool isLoading = false.obs;

  // ── Availability (today by default; user can tap another day) ──
  /// The next 7 days the user can glance at (today + 6).
  late final List<DateTime> availabilityDays = List.generate(
    7,
        (i) => DateTime.now().add(Duration(days: i)),
  );
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxList<DateSlot> daySlots = <DateSlot>[].obs;
  final RxBool isLoadingSlots = false.obs;

  int? _helperId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HelperListModel) {
      final helperData = Get.arguments as HelperListModel;
      loadHelperDetail(helperData.id);
    } else if (Get.arguments is int) {
      loadHelperDetail(Get.arguments as int);
    }
  }

  Future<void> loadHelperDetail(int id) async {
    _helperId = id;
    isLoading.value = true;
    try {
      helper = await _helperRepo.getHelperDetail(id, profileType: 'customer');
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      // keep null
    } finally {
      isLoading.value = false;
    }
    // Once we know the helper, load today's availability.
    await loadAvailability(selectedDay.value);
  }

  Future<void> refreshProfile() async {
    final id = _helperId;
    if (id == null) return;
    await loadHelperDetail(id);
  }

  /// Loads the helper's slots for [day].
  Future<void> loadAvailability(DateTime day) async {
    final id = _helperId;
    final repo = _availabilityRepo;
    if (id == null || repo == null) return;
    selectedDay.value = day;
    isLoadingSlots.value = true;
    daySlots.clear();
    try {
      final all = await repo.getHelperDateSlots(
        id,
        day,
        profileType: 'customer',
      );
      daySlots.value = all;
    } catch (_) {
      daySlots.clear();
    } finally {
      isLoadingSlots.value = false;
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<dynamic> get customerReviews {
    final reviews = helper?.reviews ?? const <dynamic>[];
    return reviews.where(_isCustomerReview).toList(growable: false);
  }

  bool _isCustomerReview(dynamic review) {
    if (review is! Map) return false;

    final rawRole = review['reviewer_role'] ??
        review['given_by_role'] ??
        review['from_role'] ??
        review['role'];
    final role = rawRole?.toString().trim().toUpperCase();
    if (role != null && role.isNotEmpty) {
      return role == 'CUSTOMER' || role == 'CLIENT';
    }

    if (review['is_provider_review'] == true) return false;
    if (review['is_customer_review'] == true) return true;
    return review['customer'] is Map;
  }

  double get rating {
    final ratings = customerReviews
        .map(_reviewRating)
        .whereType<double>()
        .where((value) => value >= 1 && value <= 5)
        .toList(growable: false);
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  double? _reviewRating(dynamic review) {
    if (review is! Map) return null;
    final value = review['rating'] ?? review['stars'] ?? review['score'];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int get totalTasks => helper?.totalTasks ?? 0;
  int get reviewCount => customerReviews.length;
}
