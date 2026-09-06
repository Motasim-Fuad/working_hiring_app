// ================================================================
// FILE: custom_offer_controller.dart
//   - enforces minimum budget = hourlyRate × workingHour
//   - supports image + PDF attachments
//   - fetches helper details from API if arguments are incomplete
// ================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/availability_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/order_event.dart';
import '../../../../data/repositories/availability_repository.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/helper_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../service/order_event_bus.dart';
import '../../../message/controllers/message_controller.dart';
import '../../../message/views/chat_view.dart';

class CustomOfferController extends GetxController {
  final OrderRepository _orderRepo;
  final ChatRepository _chatRepo;
  final CategoryRepository _categoryRepo;
  final UserRepository _userRepo;
  final AvailabilityRepository _availabilityRepo;
  final HelperRepository _helperRepo;

  CustomOfferController(
      this._orderRepo,
      this._chatRepo,
      this._categoryRepo,
      this._userRepo,
      this._availabilityRepo,
      this._helperRepo,
      );

  // Arguments
  String workerID = '';
  String workerName = '';
  String workerAvatar = '';
  String categoryID = '';

  // From helper detail – used to enforce minimum hours + auto price.
  int minBookingHours = 1;
  double hourlyRate = 0.0;

  // Form Controllers
  final taskTitleController = TextEditingController();
  final addressController = TextEditingController();
  final detailsController = TextEditingController();
  final budgetController = TextEditingController();

  // Observable Options
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  // Availability slots
  final RxList<DateSlot> availableSlots = <DateSlot>[].obs;
  final Rx<DateSlot?> selectedSlot = Rx<DateSlot?>(null);
  final RxBool isLoadingSlots = false.obs;
  final Rx<HourSlotCheck?> slotCheck = Rx<HourSlotCheck?>(null);
  final RxBool isCheckingSlot = false.obs;

  // Budget and hours
  final RxDouble budget = 0.0.obs;
  final RxInt workingHour = 1.obs;

  // Location
  final RxDouble selectedLat = 0.0.obs;
  final RxDouble selectedLng = 0.0.obs;

  // Attachments
  final RxList<File> attachments = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  static const int _maxFiles = 5;
  static const int _maxFileMb = 25;
  final RxBool isSending = false.obs;

  // Categories
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<CategoryModel?> selectedCategoryModel = Rx<CategoryModel?>(null);

  // ─── Minimum budget ──────────────────────────────────────────

  double get minBudget => (hourlyRate * workingHour.value).clamp(0, double.infinity).toDouble();

  // ─── Lifecycle ──────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // 1. Read arguments
    if (Get.arguments != null) {
      workerID = Get.arguments['workerID'] ?? '';
      workerName = Get.arguments['workerName'] ?? '';
      workerAvatar = Get.arguments['workerAvatar'] ?? '';
      categoryID = Get.arguments['categoryID'] ?? '';
      minBookingHours = (Get.arguments['minBookingHours'] as num?)?.toInt() ?? 1;
      hourlyRate = (Get.arguments['hourlyRate'] as num?)?.toDouble() ?? 0.0;
    }

    // 2. If we have a workerID but missing essential data, fetch from API
    if (workerID.isNotEmpty && (workerName.isEmpty || hourlyRate == 0.0 || minBookingHours < 1)) {
      _fetchHelperDetails(int.parse(workerID));
    } else {
      // Already have everything – just init UI
      _initializeForm();
    }

    // Budget listener
    budgetController.addListener(() {
      final val = double.tryParse(budgetController.text);
      if (val != null && val != budget.value) {
        // Do not clamp/rewrite while the user is typing. Rewriting after the
        // first digit made values such as 200 impossible to enter. Minimum
        // budget validation still runs before the offer is submitted.
        budget.value = val < 0 ? 0 : val;
      }
    });

    _loadCategories();
    _loadUserLocation();
  }


  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // পূর্ণাঙ্গ ঠিকানা তৈরি করুন
        List<String> parts = [];
        if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
        if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
        if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) parts.add(p.administrativeArea!);
        if (p.postalCode != null && p.postalCode!.isNotEmpty) parts.add(p.postalCode!);
        if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
        return parts.join(', ');
      }
      return ''; // fallback
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      return ''; // যদি ব্যর্থ হয়, পরে কোঅর্ডিনেট দেখাবেন
    }
  }



  // ─── Helper fetch ────────────────────────────────────────────

  Future<void> _fetchHelperDetails(int id) async {
    try {
      final helper = await _helperRepo.getHelperDetail(id, profileType: 'customer');
      // Populate fields
      workerName = helper.companyName ?? 'Helper';
      workerAvatar = helper.photo ?? '';
      hourlyRate = helper.hourlyRate ?? 0.0;
      minBookingHours = (helper.minBookingHours ?? 1).toInt();
      if (minBookingHours < 1) minBookingHours = 1;

      // If categories exist, auto-select first one
      if (helper.categories != null && helper.categories!.isNotEmpty) {
        categoryID = helper.categories!.first;
        selectedCategory.value = categoryID;
      }

      _initializeForm();
    } catch (e) {
      debugPrint('Failed to fetch helper details: $e');
      Get.snackbar('Error'.tr, 'Could not load helper information. Please try again.'.tr);
    }
  }

  void _initializeForm() {
    // Set initial working hour to minimum
    workingHour.value = minBookingHours;
    if (hourlyRate > 0) {
      final initial = minBudget;
      budget.value = initial;
      budgetController.text = initial.toInt().toString();
    } else {
      budgetController.text = '0';
    }
  }

  // ─── Data loading ────────────────────────────────────────────

  Future<void> _loadCategories() async {
    try {
      final list = await _categoryRepo.getCategories();
      categories.value = list;
      if (categoryID.isNotEmpty) {
        final intId = int.tryParse(categoryID);
        if (intId != null) {
          selectedCategoryModel.value = list.firstWhereOrNull((c) => c.id == intId);
        } else {
          selectedCategoryModel.value = list.firstWhereOrNull(
                (c) => c.title?.toLowerCase() == categoryID.toLowerCase(),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _loadUserLocation() async {
    try {
      final user = await _userRepo.getCurrentUser(profileType: 'customer');
      final lat = user.address?.lat;
      final lng = user.address?.lng;
      if (lat != null && lng != null) {
        selectedLat.value = lat is num ? lat.toDouble() : (double.tryParse(lat.toString()) ?? 0.0);
        selectedLng.value = lng is num ? lng.toDouble() : (double.tryParse(lng.toString()) ?? 0.0);
      }
    } catch (e) {
      debugPrint('[CustomOffer] _loadUserLocation failed: $e');
    }
  }

  void setSelectedLocation(double lat, double lng, {String? addressText}) async {
    selectedLat.value = lat;
    selectedLng.value = lng;

    if (addressText != null && addressText.isNotEmpty) {
      // ম্যাপ পিকার থেকে যদি সরাসরি অ্যাড্রেস আসে (ভবিষ্যতে) তাহলে তা ব্যবহার করুন
      addressController.text = addressText;
    } else {
      // নইলে reverse geocode করুন
      String address = await getAddressFromLatLng(lat, lng);
      if (address.isNotEmpty) {
        addressController.text = address;
      } else {
        // ব্যর্থ হলে কোঅর্ডিনেট দেখান (পূর্বের মতো)
        addressController.text = "Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}";
      }
    }
  }

  // ─── Budget and Hours ────────────────────────────────────────

  void updateBudget(double value) {
    final min = minBudget;
    final clamped = value < min ? min : value;
    budget.value = clamped;
    budgetController.text = clamped.toInt().toString();
  }

  List<int> get hoursOptions => List<int>.generate(10, (i) => minBookingHours + i);

  double get estimatedTotal => hourlyRate * workingHour.value;

  void selectHours(int hours) {
    workingHour.value = hours < minBookingHours ? minBookingHours : hours;
    if (hourlyRate > 0) {
      updateBudget(minBudget);
    }
    _verifyHourSlot();
  }

  // ─── Availability ────────────────────────────────────────────

  Future<void> onDateSelected(DateTime date) async {
    selectedDate.value = date;
    selectedTime.value = null;
    selectedSlot.value = null;
    slotCheck.value = null;
    availableSlots.clear();
    await _loadAvailability(date);
  }

  Future<void> _loadAvailability(DateTime date) async {
    final pid = int.tryParse(workerID) ?? 0;
    if (pid == 0) return;
    isLoadingSlots.value = true;
    try {
      final all = await _availabilityRepo.getHelperDateSlots(
        pid,
        date,
        profileType: 'customer',
      );
      availableSlots.value = all.where((s) => s.isAvailable).toList();
      if (availableSlots.isEmpty) {
        Get.snackbar('No slots'.tr, 'This helper has no available time on the selected date.'.tr);
      }
    } catch (e) {
      debugPrint('[CustomOffer] availability load failed: $e');
      Get.snackbar('Error'.tr, 'Could not load available times. Try again.'.tr);
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectSlot(DateSlot slot) {
    selectedSlot.value = slot;
    final start = slot.slot.split('-').first.trim();
    selectedTime.value = _parseTime12(start);
    _verifyHourSlot();
  }

  Future<void> _verifyHourSlot() async {
    final slot = selectedSlot.value;
    final date = selectedDate.value;
    final pid = int.tryParse(workerID) ?? 0;
    if (slot == null || date == null || pid == 0) {
      slotCheck.value = null;
      return;
    }
    final start = slot.slot.split('-').first.trim();
    isCheckingSlot.value = true;
    slotCheck.value = null;
    try {
      slotCheck.value = await _availabilityRepo.checkHelperSlot(
        pid,
        date,
        workingHour: workingHour.value,
        startTime: start,
        profileType: 'customer',
      );
    } catch (e) {
      debugPrint('[CustomOffer] slot check failed: $e');
      slotCheck.value = null;
    } finally {
      isCheckingSlot.value = false;
    }
  }

  TimeOfDay? _parseTime12(String s) {
    try {
      final dt = DateFormat('hh:mm a').parse(s.trim());
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  void selectSubCategory(String subCategory) {
    selectedSubCategory.value = subCategory;
    Get.back();
  }

  // ─── Attachments ─────────────────────────────────────────────

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) _addFile(File(image.path));
    } catch (e) {
      debugPrint('[CustomOffer] gallery pick failed: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) _addFile(File(image.path));
    } catch (e) {
      debugPrint('[CustomOffer] camera pick failed: $e');
    }
  }

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final path = result?.files.single.path;
      if (path != null) _addFile(File(path));
    } catch (e) {
      debugPrint('[CustomOffer] pdf pick failed: $e');
    }
  }

  void _addFile(File f) {
    if (attachments.length >= _maxFiles) {
      Get.snackbar('Limit reached'.tr, 'You can attach up to $_maxFiles files.');
      return;
    }
    int bytes = 0;
    try {
      bytes = f.lengthSync();
    } catch (_) {}
    if (bytes > _maxFileMb * 1024 * 1024) {
      Get.snackbar('File too large'.tr, 'Each file must be under $_maxFileMb MB.');
      return;
    }
    attachments.add(f);
  }

  void removeAttachment(File f) => attachments.remove(f);

  bool isPdf(File f) => f.path.toLowerCase().endsWith('.pdf');

  String fileName(File f) => f.path.split('/').last;

  // ─── Send Offer ──────────────────────────────────────────────

  Future<void> onSendOffer() async {
    if (isSending.value) return;

    if (taskTitleController.text.isEmpty) {
      Get.snackbar("Error".tr, "Please fill out the task title".tr, colorText: Colors.red);
      return;
    }
    if (workerID.isEmpty) {
      Get.snackbar("Error".tr, "Worker not selected".tr, colorText: Colors.red);
      return;
    }
    final category = selectedCategoryModel.value;
    if (category == null) {
      Get.snackbar("Error".tr, "Please select a category".tr, colorText: Colors.red);
      return;
    }

    if (budget.value < minBudget) {
      Get.snackbar("Budget too low".tr, "Minimum budget for ${workingHour.value} hour(s) is \$${minBudget.toStringAsFixed(0)}",
        colorText: Colors.red,
      );
      return;
    }

    if (selectedSlot.value != null) {
      final check = slotCheck.value;
      if (check == null || !check.isAvailable) {
        Get.snackbar("Slot unavailable".tr, "Please choose a start time and hours the helper is available for.".tr);
        return;
      }
    }

    if (selectedLat.value == 0.0 && selectedLng.value == 0.0) {
      await _loadUserLocation();
    }

    isSending.value = true;
    try {
      final payload = <String, dynamic>{
        'title': taskTitleController.text.trim(),
        'description': detailsController.text.trim(),
        'category': category.id,
        'amount': budget.value.toStringAsFixed(2),
        'working_hour': workingHour.value,
        'area': addressController.text.trim(),
        'lat': selectedLat.value,
        'lng': selectedLng.value,
        'provider_id': int.tryParse(workerID) ?? 0,
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

      final room = await _chatRepo.startChat(int.tryParse(workerID) ?? 0);

      if (!Get.isRegistered<MessageController>()) {
        Get.put(MessageController(_chatRepo, _orderRepo, _availabilityRepo));
      }
      final msgCtrl = Get.find<MessageController>();
      await msgCtrl.loadRooms();

      final created = await _orderRepo.createOrder(
        payload,
        attachments: attachments.isEmpty ? null : attachments.toList(),
      );

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
            endTime: created.endTime,
            createdAt: created.createdAt,
          ),
        ));
      }

      ChatModel chat;
      try {
        chat = msgCtrl.chats.firstWhere((c) => c.roomUuid == room.uuid);
      } catch (_) {
        chat = ChatModel(
          name: workerName,
          avatar: workerAvatar.isNotEmpty ? workerAvatar : '',
          lastMessage: taskTitleController.text,
          timeAgo: 'Just now',
          roomUuid: room.uuid,
          roomId: room.id,
        );
        msgCtrl.chats.add(chat);
      }

      // ORDER_CREATED is broadcast while createOrder is being processed, so
      // the customer may not be connected to this room early enough to receive
      // that WS frame. Previously we inserted a fake negative-id / `Now` card.
      // That card always sorted after subsequent normal messages and survived
      // history refreshes until another order event (for example COUNTER)
      // replaced it. Load the persisted server message instead, which carries
      // the real chat-message id and timestamp used by both participants.
      await msgCtrl.loadMessages(chat);

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      Get.off(() => ChatView(chat: chat));
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      debugPrint('CustomOfferController.onSendOffer error: $e');
      Get.snackbar("Error".tr, "Failed to send offer. Please try again.".tr);
    } finally {
      isSending.value = false;
    }
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
