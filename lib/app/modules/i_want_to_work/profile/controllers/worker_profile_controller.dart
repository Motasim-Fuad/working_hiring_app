// lib/modules/i_want_to_work/profile/controllers/worker_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/availability_repository.dart';
import '../../../../data/models/availability_model.dart';
import '../../../../service/api_service.dart';
import '../../../../service/shared_prefs_helper.dart';
import '../../../../service/websocket_service.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../routes/app_pages.dart';
import '../../../message/controllers/message_controller.dart';

class WorkerProfileController extends GetxController {
  final UserRepository _userRepo;
  final AvailabilityRepository _availabilityRepo;

  WorkerProfileController(this._userRepo, this._availabilityRepo);

  // Text controllers for editing
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Reactive display fields
  final RxString displayName = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxString displayEmail = ''.obs;

  // Photo
  final RxString networkPhotoUrl = ''.obs;
  final Rx<File?> pickedPhoto = Rx<File?>(null);
  final RxBool isUploadingPhoto = false.obs;
  final ImagePicker _picker = ImagePicker();
  var avatar = AppImages.profilePlaceholder.obs;

  // Other profile data
  var strikes = 1.obs;
  var completionRate = 98.obs;
  var isVerified = false.obs;
  var isAVAILABLE =false.obs;
  final RxBool isLoading = false.obs;

  // Availability data
  final RxList<WeeklyDayAvailability> weeklyAvailability = <WeeklyDayAvailability>[].obs;
  final RxBool isAvailabilityLoading = false.obs;

  UserModel? _user;

  // ImageProvider get displayPhoto {
  //   if (pickedPhoto.value != null) return FileImage(pickedPhoto.value!);
  //   if (networkPhotoUrl.value.isNotEmpty) {
  //     return NetworkImage(networkPhotoUrl.value);
  //   }
  //   return AssetImage(avatar.value);
  // }

  ImageProvider? get displayPhoto {
    if (pickedPhoto.value != null) {
      return FileImage(pickedPhoto.value!);
    }

    if (networkPhotoUrl.value.trim().isNotEmpty) {
      return NetworkImage(networkPhotoUrl.value);
    }

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    fetchWeeklyAvailability(); // call independently
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      _user = await _userRepo.getCurrentUser(profileType: 'provider');
      isVerified.value = _user!.providerVerificationStatus == 'APPROVED';

      final firstName = _user!.firstName ?? '';
      final lastName = _user!.lastName ?? '';
      displayName.value = '$firstName $lastName'.trim();
      displayPhone.value = _user!.phone ?? '';
      displayEmail.value = _user!.email ?? '';

      firstNameController.text = firstName;
      lastNameController.text = lastName;
      phoneController.text = _user!.phone ?? '';
      networkPhotoUrl.value = _user!.photo ?? '';
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeeklyAvailability() async {
    isAvailabilityLoading.value = true;
    try {
      print("🔄 Fetching weekly availability...");
      final list = await _availabilityRepo.getWeeklyAvailability(profileType: 'provider');
      print("✅ Fetched ${list.length} days: ${list.map((d) => '${d.day}:${d.dayStatus}').join(', ')}");
      weeklyAvailability.assignAll(list);
    } on ApiException catch (e) {
      print("❌ API error: ${e.message}");
      Get.snackbar("Error".tr, "Could not load availability: ${e.message}");
    } catch (e) {
      print("❌ Unexpected error: $e");
      Get.snackbar("Error".tr, "Something went wrong while loading availability".tr);
    } finally {
      isAvailabilityLoading.value = false;
    }
  }

  // Call this from a pull-to-refresh or a button
  Future<void> refreshAll() async {
    await Future.wait([loadProfile(), fetchWeeklyAvailability()]);
  }
  Future<void> updateName() async {
    try {
      await _userRepo.updateCurrentUser({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      }, profileType: 'provider');
      displayName.value =
          '${firstNameController.text} ${lastNameController.text}'.trim();
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Something went wrong".tr);
    }
  }

  Future<void> updatePhone() async {
    try {
      await _userRepo.updateCurrentUser({
        'phone': phoneController.text.trim(),
      }, profileType: 'provider');
      displayPhone.value = phoneController.text.trim();
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Something went wrong".tr);
    }
  }

  Future<void> pickImage(bool fromCamera) async {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    try {
      final picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      pickedPhoto.value = File(picked.path);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Could not pick image'.tr);
    }
  }

  Future<void> updatePhoto() async {
    if (pickedPhoto.value == null) {
      Get.snackbar('No photo selected'.tr, 'Pick an image first'.tr);
      return;
    }
    isUploadingPhoto.value = true;
    try {
      final updated = await _userRepo.updateCurrentUser(
        <String, dynamic>{},
        profileType: 'provider',
        photoFile: pickedPhoto.value,
      );
      networkPhotoUrl.value = updated.photo ?? networkPhotoUrl.value;
      pickedPhoto.value = null;
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Something went wrong'.tr);
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> signOut() async {
    if (Get.isRegistered<WebSocketService>()) {
      final ws = Get.find<WebSocketService>();
      await ws.disconnectChat();
      await ws.disconnectNotifications();
    }
    if (Get.isRegistered<MessageController>()) {
      Get.delete<MessageController>(force: true);
    }
    await SharedPrefsHelper.clearAll();
    Get.offAllNamed(Routes.SIGN_IN);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}