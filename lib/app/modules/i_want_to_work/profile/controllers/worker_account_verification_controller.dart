import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:working_hiring/app/core/constants/app_constants.dart';
import 'package:working_hiring/app/service/shared_prefs_helper.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../main/controllers/main_controller.dart';
import '../../dashboard/controllers/worker_dashboard_controller.dart';
import '../views/worker_account_verification_camera_view.dart';
import '../views/worker_account_verification_result_view.dart';
import '../views/worker_account_verification_instruction_view.dart';

class WorkerAccountVerificationController extends GetxController {
  final UserRepository _userRepo;

  WorkerAccountVerificationController(this._userRepo);

  CameraController? cameraController;
  final isCameraInitialized = false.obs;

  final selectedDocumentType = 'ID Card'.obs;
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final idNumberController = TextEditingController();

  final idCardImagePath = ''.obs;
  final isVerificationSuccess = false.obs;
  final isVerified = false.obs;
  final verificationStatus = ''.obs;
  final hasSubmittedDocuments = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerificationStatus();
  }

  Future<void> fetchVerificationStatus() async {
    try {
      final status = await _userRepo.getVerificationStatus();
      if (status != null) {
        verificationStatus.value = status['status'] ?? '';
        hasSubmittedDocuments.value = status['document_type'] != null;
        if (status['is_verified'] == true) {
          isVerified.value = true;
          isVerificationSuccess.value = true;
        }
      }
    } catch (_) {
      // No verification record yet — user needs to submit
    }
  }

  void setDocumentType(String type) {
    selectedDocumentType.value = type;
  }

  /// Maps the UI-facing document type label to the backend enum value.
  String _mapDocumentType(String uiType) {
    switch (uiType) {
      case 'Passport':
        return 'PASSPORT';
      case 'Driver\'s License':
        return 'DRIVING_LICENSE';
      case 'ID Card':
      default:
        return 'NID';
    }
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      idCardImagePath.value = image.path;
      _submitVerification(image.path);
    }
  }

  void captureImage() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        final image = await cameraController!.takePicture();
        idCardImagePath.value = image.path;
        _submitVerification(image.path);
      } catch (e) {
        Get.snackbar('Error'.tr, 'Failed to capture image: $e');
      }
    }
  }

  Future<void> _submitVerification(String imagePath) async {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Convert dob from MM/dd/yyyy to dd-MM-yyyy for backend
      String formattedDob = dobController.text;
      try {
        final parsed = DateFormat('MM/dd/yyyy').parse(dobController.text);
        formattedDob = DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        // If parsing fails, send as-is
      }

      await _userRepo.submitVerification(
        fields: {
          'full_name': nameController.text.trim(),
          'document_id': idNumberController.text.trim(),
          'dob': formattedDob,
          'document_type': _mapDocumentType(selectedDocumentType.value),
        },
        documentFilePath: imagePath,
      );

      isVerificationSuccess.value = true;
      isVerified.value = true;
    } on ApiException catch (e) {
      isVerificationSuccess.value = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar('Verification Failed', e.message);
      Get.off(() => WorkerAccountVerificationResultView());
      return;
    } catch (e) {
      isVerificationSuccess.value = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar('Error'.tr, 'Verification request failed. Please check your connection and try again.'.tr);
      Get.off(() => WorkerAccountVerificationResultView());
      return;
    }

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.off(() => WorkerAccountVerificationResultView());
  }

  void leaveVerification() {
    Get.back();
  }

  Future<void> finishVerification() async {
    await SharedPrefsHelper.setString(
      AppConstants.defaultProfile,
      'PROVIDER',
    );

    // Preserve the existing Main route and controller whenever verification
    // was opened from the provider gate. This prevents stale role-switch state.
    if (Get.isRegistered<MainController>()) {
      final mainController = Get.find<MainController>();
      mainController.changePhase(2);
      if (Get.isRegistered<WorkerDashboardController>()) {
        await Get.find<WorkerDashboardController>().refreshAccess();
      }
      Get.until((route) => route.settings.name == Routes.MAIN);
      return;
    }

    Get.offAllNamed(Routes.MAIN);
  }

  void retryVerification() {
    Get.back();
  }

  void submit() {
    if (nameController.text.isEmpty ||
        dobController.text.isEmpty ||
        idNumberController.text.isEmpty) {
      Get.snackbar('Error'.tr, 'Please fill all fields'.tr);
      return;
    }
    Get.to(() => WorkerAccountVerificationInstructionView());
  }

  Future<void> initializeCamera() async {
    try {
      if (cameraController != null) {
        await cameraController!.dispose();
      }

      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        isCameraInitialized.value = true;
      }
    } catch (e) {
      isCameraInitialized.value = false;
    }
  }

  void goToCamera() {
    Get.to(() => WorkerAccountVerificationCameraView());
    initializeCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    nameController.dispose();
    dobController.dispose();
    idNumberController.dispose();
    super.onClose();
  }
}
