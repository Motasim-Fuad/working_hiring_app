import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/availability_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/availability_model.dart';
import '../../../../service/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/filter_modal.dart';
import '../widgets/proposal_modal.dart';

enum SlotState { available, booked, unavailable }
enum DayColor { available, booked, none }

class WorkerHomeController extends GetxController {
  final OrderRepository _orderRepo;
  final AvailabilityRepository _availabilityRepo;
  final UserRepository _userRepo;

  WorkerHomeController(this._orderRepo, this._availabilityRepo, this._userRepo);

  final isVerified = false.obs;
  final isVerifyBannerVisible = true.obs;

  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedHour = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  final RxString startTime = '09:00 AM'.obs;
  final RxString endTime = '05:00 PM'.obs;
  final RxList<String> selectedDaysOfWeek = <String>[].obs;

  static const List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final RxMap<DateTime, Map<String, SlotState>> slotStates = <DateTime, Map<String, SlotState>>{}.obs;
  final RxSet<DateTime> availableDays = <DateTime>{}.obs;

  final RxBool isLoadingAvailability = false.obs;
  final RxBool isSavingTime = false.obs;
  final RxBool isLoadingInitial = false.obs; // overall loading state

  final RxList<OrderModel> jobs = <OrderModel>[].obs;
  final RxBool isLoadingJobs = false.obs;
  final RxList<OrderModel> nextJobs = <OrderModel>[].obs;

  // Backend weekly availability snapshot for sync check
  List<WeeklyDayAvailability>? _lastBackendAvailability;

  final List<String> allTimeSlots = const [
    '12:00 AM - 01:00 AM', '01:00 AM - 02:00 AM', '02:00 AM - 03:00 AM',
    '03:00 AM - 04:00 AM', '04:00 AM - 05:00 AM', '05:00 AM - 06:00 AM',
    '06:00 AM - 07:00 AM', '07:00 AM - 08:00 AM', '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM', '10:00 AM - 11:00 AM', '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM', '01:00 PM - 02:00 PM', '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM', '04:00 PM - 05:00 PM', '05:00 PM - 06:00 PM',
    '06:00 PM - 07:00 PM', '07:00 PM - 08:00 PM', '08:00 PM - 09:00 PM',
    '09:00 PM - 10:00 PM', '10:00 PM - 11:00 PM', '11:00 PM - 12:00 AM',
  ];

  final List<String> hoursList = const [
    '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
    '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM', '10:00 PM',
  ];

  bool get isPatternSynced {
    final b = _lastBackendAvailability;
    if (b == null || selectedDaysOfWeek.isEmpty) return false;
    final backendDays = b.where((d) => d.isAvailable).map((d) => d.day).toSet();
    if (backendDays.length != selectedDaysOfWeek.length || !backendDays.containsAll(selectedDaysOfWeek))
      return false;
    if (b.isNotEmpty) {
      final bStart = _to12h(b.first.startTime ?? '');
      final bEnd = _to12h(b.first.endTime ?? '');
      if (bStart != startTime.value || bEnd != endTime.value) return false;
    }
    return true;
  }

  int get totalAvailableDays {
    final y = selectedYear.value, mo = selectedMonth.value;
    final daysInMonth = DateTime(y, mo + 1, 0).day;
    int c = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (_availableSlotCount(DateTime(y, mo, d)) > 0) c++;
    }
    return c;
  }

  int get totalAvailableSlots {
    final y = selectedYear.value, mo = selectedMonth.value;
    final daysInMonth = DateTime(y, mo + 1, 0).day;
    int c = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      c += _availableSlotCount(DateTime(y, mo, d));
    }
    return c;
  }



  SlotState effectiveSlotState(DateTime date, String slot) {
    final norm = DateTime(date.year, date.month, date.day);

    // ধাপ ১: যদি এই তারিখের জন্য কোনো এক্সেপশন (ম্যাপ) থাকে, সেটাই চূড়ান্ত
    final dateMap = slotStates[norm];
    if (dateMap != null && dateMap.containsKey(slot)) {
      return dateMap[slot]!; // available, booked, বা unavailable
    }

    // ধাপ ২: কোনো এক্সেপশন না থাকলে উইকলি প্যাটার্ন ফলব্যাক
    final dayName = weekDays[norm.weekday - 1];
    if (selectedDaysOfWeek.contains(dayName) &&
        _slotsInRange(startTime.value, endTime.value).contains(slot)) {
      return SlotState.available;
    }

    return SlotState.unavailable;
  }


  int _availableSlotCount(DateTime date) {
    int c = 0;
    for (final slot in allTimeSlots) {
      if (effectiveSlotState(date, slot) == SlotState.available) c++;
    }
    return c;
  }

  DayColor colorForDate(DateTime date) {
    bool anyAvailable = false;
    bool anyBooked = false;
    for (final slot in allTimeSlots) {
      final s = effectiveSlotState(date, slot);
      if (s == SlotState.available) {
        anyAvailable = true;
      } else if (s == SlotState.booked) {
        anyBooked = true;
      }
    }
    if (anyAvailable) return DayColor.available;
    if (anyBooked) return DayColor.booked;
    return DayColor.none;
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    selectedYear.value = now.year;
    selectedMonth.value = now.month;

    ever(selectedYear, (_) => loadMonthAvailability());
    ever(selectedMonth, (_) => loadMonthAvailability());

    // Initial load with a small delay to let everything settle
    Future.delayed(Duration(milliseconds: 300), () {
      loadInitialData();
    });
  }

  // ------------------------------------------------------------------------
  // Main load method – now with error logging and loading state
  // ------------------------------------------------------------------------
  Future<void> loadInitialData() async {
    isLoadingInitial.value = true;
    print('🔄 [WorkerHome] loadInitialData started');

    try {
      // 1. Load weekly availability (this sets selectedDaysOfWeek, start/end)
      await loadWeeklyDayList();

      // 2. Load jobs & next jobs
      await Future.wait([
        loadJobs(),
        loadNextJobs(),
        loadVerificationStatus(),
      ]);

      // 3. Build month availability from the weekly pattern
      await loadMonthAvailability();

      // 4. Load slots for the selected date (if any)
      if (selectedDate.value != null) {
        await loadSlotsForDate(selectedDate.value!);
      }

      print('✅ [WorkerHome] loadInitialData completed successfully');
    } catch (e, stack) {
      print('❌ [WorkerHome] loadInitialData error: $e');
      print(stack);
      Get.snackbar('Error'.tr, 'Could not load your data. Please try again.'.tr,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingInitial.value = false;
    }
  }

  // ------------------------------------------------------------------------
  // Load weekly availability (provider’s recurring schedule)
  // ------------------------------------------------------------------------
  Future<void> loadWeeklyDayList() async {
    try {
      final availabilities = await _availabilityRepo.getWeeklyAvailability();
      _lastBackendAvailability = availabilities;
      print('📆 [WorkerHome] Weekly availability: ${availabilities.length} entries');

      if (availabilities.isNotEmpty) {
        selectedDaysOfWeek.value = availabilities
            .where((d) => d.isAvailable)
            .map((d) => d.day)
            .toList();
        final first = availabilities.first;
        if (first.startTime != null) startTime.value = _to12h(first.startTime!);
        if (first.endTime != null) endTime.value = _to12h(first.endTime!);
        print('   -> Days: ${selectedDaysOfWeek.join(', ')}');
        print('   -> Time: ${startTime.value} - ${endTime.value}');
      } else {
        print('   -> No weekly availability found, using defaults');
      }
    } catch (e) {
      print('⚠️ [WorkerHome] loadWeeklyDayList error: $e');
      // do not rethrow, continue with defaults
    }
  }

  // ------------------------------------------------------------------------
  // Load jobs (for the provider)
  // ------------------------------------------------------------------------
  Future<void> loadJobs() async {
    isLoadingJobs.value = true;
    try {
      final result = await _orderRepo.getProviderOrders();
      jobs.value = result;
      print('📋 [WorkerHome] Jobs loaded: ${result.length}');
    } catch (e) {
      print('⚠️ [WorkerHome] loadJobs error: $e');
      jobs.clear();
    } finally {
      isLoadingJobs.value = false;
    }
  }

  // ------------------------------------------------------------------------
  // Load next jobs (upcoming)
  // ------------------------------------------------------------------------
  Future<void> loadNextJobs() async {
    try {
      final result = await _orderRepo.getNextJobOrders();
      nextJobs.value = result;
      print('📅 [WorkerHome] Next jobs loaded: ${result.length}');
    } catch (e) {
      print('⚠️ [WorkerHome] loadNextJobs error: $e');
      nextJobs.clear();
    }
  }

  // ------------------------------------------------------------------------
  // Load verification status
  // ------------------------------------------------------------------------
  Future<void> loadVerificationStatus() async {
    try {
      final status = await _userRepo.getVerificationStatus(profileType: 'provider');
      if (status != null) {
        isVerified.value = status['is_verified'] == true;
        print('🔐 [WorkerHome] Verification status: ${isVerified.value}');
      }
    } catch (e) {
      print('⚠️ [WorkerHome] loadVerificationStatus error: $e');
    }
  }

  // ------------------------------------------------------------------------
  // Load monthly available days (based on weekly pattern)
  // ------------------------------------------------------------------------
  Future<void> loadMonthAvailability() async {
    final year = selectedYear.value;
    final month = selectedMonth.value;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final newAvailable = <DateTime>{};
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dayName = weekDays[date.weekday - 1];
      if (selectedDaysOfWeek.contains(dayName)) {
        newAvailable.add(date);
      }
    }
    availableDays.assignAll(newAvailable);
    print('📆 [WorkerHome] Month availability: ${availableDays.length} days');
  }

  Future<void> loadSlotsForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    isLoadingAvailability.value = true;
    try {
      final dateStr = DateFormat('dd-MM-yyyy').format(normalized);
      final slots = await _availabilityRepo.getDateSlotList(dateStr);

      final map = <String, SlotState>{};
      for (final s in slots) {
        // ধরুন s.status থেকে স্ট্রিং আসছে (AVAILABLE/BOOKED/UNAVAILABLE)
        // অথবা s.isAvailable, s.isBooked বুলিয়ান। নিচে সব কভার করা হলো:
        if (s.status == 'BOOKED' || s.isBooked == true) {
          map[s.slot] = SlotState.booked;
        } else if (s.status == 'AVAILABLE' || s.isAvailable == true) {
          map[s.slot] = SlotState.available;
        } else if (s.status == 'UNAVAILABLE') {
          // 🔥 মূল ফিক্স: অফ থাকা স্লটকেও ম্যাপে রাখুন
          map[s.slot] = SlotState.unavailable;
        }
      }

      // যদি কোনো স্লট API তে না-ও আসে (সেটা ডিফল্ট প্যাটার্নের অংশ),
      // তাহলে আমরা ম্যাপে রাখব না, কারন effectiveSlotState তাতে প্যাটার্ন ফলব্যাক করবে।
      slotStates[normalized] = map;
      slotStates.refresh();
    } catch (e) {
      print('⚠️ [WorkerHome] loadSlotsForDate error: $e');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  // ------------------------------------------------------------------------
  // Day selection & toggling
  // ------------------------------------------------------------------------
  void toggleDayOfWeek(String day) {
    if (selectedDaysOfWeek.contains(day)) {
      selectedDaysOfWeek.remove(day);
    } else {
      selectedDaysOfWeek.add(day);
    }
    loadMonthAvailability();
  }

  Future<void> setDailyAvailableTime() async {
    if (selectedDaysOfWeek.isEmpty) {
      Get.snackbar("Select days".tr, "Please pick at least one day.".tr);
      return;
    }
    isSavingTime.value = true;
    try {
      await _availabilityRepo.setWeeklyAvailability({
        'days': selectedDaysOfWeek.toList(),
        'start_time': startTime.value,
        'end_time': endTime.value,
      });
      print('✅ [WorkerHome] Weekly availability saved');

      await loadWeeklyDayList();
      await loadMonthAvailability();
      if (selectedDate.value != null) {
        await loadSlotsForDate(selectedDate.value!);
      }

    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      print('❌ [WorkerHome] setDailyAvailableTime error: $e');
      Get.snackbar("Error".tr, "Could not save. Please try again.".tr);
    } finally {
      isSavingTime.value = false;
    }
  }

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (selectedDate.value == normalized) {
      selectedDate.value = null;
    } else {
      selectedDate.value = normalized;
      loadSlotsForDate(normalized);
    }
  }

  Future<void> toggleTimeSlot(String slot) async {
    final date = selectedDate.value;
    if (date == null) return;
    final norm = DateTime(date.year, date.month, date.day);

    final current = effectiveSlotState(norm, slot);
    if (current == SlotState.booked) return;

    final makeAvailable = current != SlotState.available;

    try {
      final dateStr = DateFormat('dd-MM-yyyy').format(norm);
      final parts = slot.split(' - ');
      await _availabilityRepo.setSlotException(dateStr, {
        'start_time': parts[0].trim(),
        'end_time': parts.length > 1 ? parts[1].trim() : '',
        'is_available': makeAvailable,
      });
      await loadSlotsForDate(norm);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      print('❌ [WorkerHome] toggleTimeSlot error: $e');
    }
  }

  Future<void> setSpecialDate(DateTime date,
      {required bool isAvailable, String? startTime, String? endTime}) async {
    final norm = DateTime(date.year, date.month, date.day);
    try {
      final dateStr = DateFormat('dd-MM-yyyy').format(norm);
      final st = startTime ?? this.startTime.value;
      final et = endTime ?? this.endTime.value;
      await _availabilityRepo.setSpecialDate(dateStr, {
        'date_status': isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
        'start_time': st,
        'end_time': et,
      });
      await loadSlotsForDate(norm);
      // Get.snackbar("Updated", isAvailable ? "Date marked available." : "Date cleared.",
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Color(0xFF6CA34D),
      //     colorText: Colors.white,
      //     margin: EdgeInsets.all(16),
      //     borderRadius: 12);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      print('❌ [WorkerHome] setSpecialDate error: $e');
      Get.snackbar("Error".tr, "Could not update. Please try again.".tr);
    }
  }

  // ------------------------------------------------------------------------
  // Helper methods
  // ------------------------------------------------------------------------
  List<String> _slotsInRange(String start, String end) {
    final startMin = _toMinutes(start);
    var endMin = _toMinutes(end);
    if (endMin <= startMin) endMin = 1440;
    return allTimeSlots.where((slot) {
      final parts = slot.split(' - ');
      final sMin = _toMinutes(parts[0].trim());
      var eMin = parts.length > 1 ? _toMinutes(parts[1].trim()) : sMin + 60;
      if (eMin == 0) eMin = 1440;
      return sMin >= startMin && eMin <= endMin;
    }).toList();
  }

  int _toMinutes(String t) {
    try {
      final m = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false)
          .firstMatch(t.trim());
      if (m == null) return 0;
      var h = int.parse(m.group(1)!);
      final min = int.parse(m.group(2)!);
      final period = m.group(3)!.toUpperCase();
      if (period == 'PM' && h != 12) h += 12;
      if (period == 'AM' && h == 12) h = 0;
      return h * 60 + min;
    } catch (_) {
      return 0;
    }
  }

  String _to12h(String t) {
    try {
      final parts = t.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1].substring(0, 2) : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${h12.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return t;
    }
  }

  String get monthLabel =>
      DateFormat('MMMM yyyy').format(DateTime(selectedYear.value, selectedMonth.value));

  // ------------------------------------------------------------------------
  // Proposal / filter methods
  // ------------------------------------------------------------------------
  final proposedBudget = ''.obs;
  final Rxn<OrderModel> activeJobForProposal = Rxn<OrderModel>();
  double get clientPays => double.tryParse(proposedBudget.value) ?? 0.0;
  double get serviceFee => clientPays * 0.20;
  double get workerRevenue => clientPays * 0.80;

  final filterCategory = 'Furniture assembly'.obs;
  final filterBudget = 'Highest to Lowest'.obs;
  final filterDate = 'Newest to Oldest'.obs;

  void showVerificationUi() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Verify your account to continue".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 16),
              Text(
                "Your account isn't verified yet.\nTo send work requests and get hired,\nplease complete your verification.".tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF6DA54B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Cancel".tr,
                          style: TextStyle(color: Color(0xFF6DA54B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { Get.back(); navigateToVerification(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6DA54B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text("Verify now".tr,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToVerification() => Get.toNamed(Routes.WORKER_ACCOUNT_VERIFICATION);

  void openTaskDetails(OrderModel job) {
    Get.bottomSheet(
      TaskDetailSheet(
        job: {
          'title': job.title ?? '',
          'category': job.categoryName ?? '',
          'location': job.address ?? '',
          'price': job.amount ?? 0,
          'date': job.workingDate ?? '',
          'time': job.workingStartTime ?? '',
          'postedBy': job.customerName ?? '',
        },
        onPressedBtn: () => openProposalModal(job),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openFilter() => Get.bottomSheet(FilterModal(), isScrollControlled: true);

  Future<void> applyFilter() async {
    try {
      isLoadingJobs.value = true;
      jobs.value = await _orderRepo.getProviderOrders(
        query: filterCategory.value != 'All' ? filterCategory.value : null,
      );
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } finally {
      isLoadingJobs.value = false;
    }
    Get.back();
  }

  void resetFilter() {
    filterCategory.value = 'Furniture assembly';
    filterBudget.value = 'Highest to Lowest';
    filterDate.value = 'Newest to Oldest';
    loadJobs();
  }

  void openProposalModal(OrderModel job) {
    proposedBudget.value = '';
    activeJobForProposal.value = job;
    Get.dialog(ProposalModal());
  }

  Future<void> submitProposal(String shortBio) async {
    final job = activeJobForProposal.value;
    if (job == null) return;
    final budget = double.tryParse(proposedBudget.value);
    if (budget == null || budget <= 0) {
      Get.snackbar("Error".tr, "Please enter a valid budget.".tr);
      return;
    }
    try {
      await _orderRepo.sendProviderCounterOffer(job.id, budget, shortBio);
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    }
  }
}