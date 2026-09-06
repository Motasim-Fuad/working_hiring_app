// lib/modules/i_need_help/profile/controllers/profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/models/user_model.dart';
import '../../../../service/api_service.dart';
import '../../../../service/shared_prefs_helper.dart';
import '../../../../service/websocket_service.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../routes/app_pages.dart';
import '../../../message/controllers/message_controller.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepo;

  ProfileController(this._userRepo);

  // -- TextEditingControllers (for editing) --
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // -- Observables for UI (auto‑update) --
  final RxString displayName = ''.obs;      // ← নতুন
  final RxString displayPhone = ''.obs;     // ← নতুন
  final RxString userEmail = ''.obs;

  // -- Photo --
  var avatar = AppImages.alexSmith.obs;
  final RxString networkPhotoUrl = ''.obs;
  final Rx<File?> pickedPhoto = Rx<File?>(null);
  final RxBool isUploadingPhoto = false.obs;
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  UserModel? _user;

  // -- Referral --
  final RxString referralCode = ''.obs;
  final RxBool isLoadingReferral = false.obs;

  // -- Reviews --
  final RxList<Map<String, dynamic>> myReviews = <Map<String, dynamic>>[].obs;

  // -- Computed photo provider --
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
    loadReferralData();
    loadMyReviews();
  }

  // ---------- Load Profile ----------
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      _user = await _userRepo.getCurrentUser(profileType: 'customer');
      final fullName =
      '${_user!.firstName ?? ''} ${_user!.lastName ?? ''}'.trim();

      // Update controllers
      nameController.text = fullName;
      phoneController.text = _user?.phone ?? '';

      // Update observables
      displayName.value = fullName;
      displayPhone.value = _user?.phone ?? '';
      userEmail.value = _user?.email ?? '';
      networkPhotoUrl.value = _user?.photo ?? '';
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      // Silently ignore – keep existing values
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- Update Profile (Name + Phone) ----------
  Future<void> onUpdateProfile() async {
    try {
      final parts = nameController.text.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await _userRepo.updateCurrentUser({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phoneController.text.trim(),
      }, profileType: 'customer');

      // ← UI আপডেট
      final newFullName = '$firstName $lastName'.trim();
      displayName.value = newFullName;
      displayPhone.value = phoneController.text.trim();

      Get.back();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Something went wrong".tr);
    }
  }

  // ---------- Update Photo ----------
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
        profileType: 'customer',
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

  // ---------- Referral ----------
  Future<void> loadReferralData() async {
    isLoadingReferral.value = true;
    try {
      final code = await _userRepo.getReferralCode();
      referralCode.value = code ?? '';
    } catch (_) {
      referralCode.value = '';
    } finally {
      isLoadingReferral.value = false;
    }
  }

  // ---------- Reviews ----------
  Future<void> loadMyReviews() async {
    try {
      myReviews.value = await _userRepo.getCustomerReviews();
    } catch (_) {}
  }

  // ---------- Sign Out ----------
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

  void updateLanguage(String langCode) {
    try {
      _userRepo.setLanguage(langCode);
    } catch (_) {}
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}