import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';
import '../views/reset_password_confirm_view.dart';
import '../../../../routes/app_pages.dart';

class PasswordResetController extends GetxController {
  final AuthRepository _authRepo;

  PasswordResetController(this._authRepo);

  final emailController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();

  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final passwordController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();

  final RxBool isRequestingOtp = false.obs;
  final RxBool isResettingPassword = false.obs;

  final RxBool isEmailValid = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString passwordStrength = ''.obs;
  final Rx<Color> strengthColor = Colors.grey.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateEmailRealTime(String value) {
    if (GetUtils.isEmail(value)) {
      isEmailValid.value = true;
    } else {
      isEmailValid.value = false;
    }
  }

  void updatePasswordStrength(String value) {
    if (value.isEmpty) {
      passwordStrength.value = '';
      strengthColor.value = Colors.grey;
      return;
    }

    if (value.length < 6) {
      passwordStrength.value = 'Very Weak';
      strengthColor.value = Colors.red;
    } else if (value.length < 8) {
      passwordStrength.value = 'Weak';
      strengthColor.value = Colors.orange;
    } else if (value.contains(RegExp(r'[a-zA-Z]')) && value.contains(RegExp(r'[0-9]')) && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    } else if (value.length >= 8 && value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]')) && value.contains(RegExp(r'[0-9]')) && value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Strong';
      strengthColor.value = Colors.green;
    } else {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    }
  }

  Future<void> requestResetOtp() async {
    if (!emailFormKey.currentState!.validate()) return;

    isRequestingOtp.value = true;
    try {
      await _authRepo.requestPasswordReset(emailController.text.trim());
      Get.to(() => ResetPasswordConfirmView(), arguments: {'email': emailController.text.trim()});
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isRequestingOtp.value = false;
    }
  }

  Future<void> resetPasswordConfirm() async {
    if (!resetFormKey.currentState!.validate()) return;

    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      Get.snackbar("Error".tr, "Please enter the complete 6-digit OTP".tr);
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar("Error".tr, "Please enter a new password".tr);
      return;
    }

    isResettingPassword.value = true;
    try {
      await _authRepo.confirmPasswordReset(
        emailController.text.trim(),
        otp,
        passwordController.text,
      );
      emailController.clear();
      passwordController.clear();
      for (var c in otpControllers) {
        c.clear();
      }
      Get.offAllNamed(Routes.SIGN_IN);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isResettingPassword.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.onClose();
  }
}
