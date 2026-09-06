import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../service/shared_prefs_helper.dart';
import '../../../../service/websocket_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_pages.dart';
import '../views/otp_verify_view.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo;

  LoginController(this._authRepo);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final emailEntryFormKey = GlobalKey<FormState>();

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final RxBool isPasswordLoginLoading = false.obs;
  final RxBool isOtpVerifyLoading = false.obs;
  final RxBool isOtpRequestLoading = false.obs;
  final RxBool isGoogleLoginLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final RxBool isEmailValid = false.obs;
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
    } else if (value.length < 6) {
      passwordStrength.value = 'Very Weak';
      strengthColor.value = Colors.red;
    } else if (value.length < 8) {
      passwordStrength.value = 'Weak';
      strengthColor.value = Colors.orange;
    } else if (value.contains(RegExp(r'[a-zA-Z]')) &&
        value.contains(RegExp(r'[0-9]')) &&
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    } else if (value.length >= 8 &&
        value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[a-z]')) &&
        value.contains(RegExp(r'[0-9]')) &&
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordStrength.value = 'Strong';
      strengthColor.value = Colors.green;
    } else {
      passwordStrength.value = 'Good';
      strengthColor.value = Colors.blue;
    }
  }

  Future<void> _storeTokensAndNavigate(String access, String refresh,
      {String? defaultProfile}) async {
    await SharedPrefsHelper.setString(AppConstants.token, access);
    await SharedPrefsHelper.setString(AppConstants.refreshToken, refresh);
    final normalizedProfile = defaultProfile?.trim().toUpperCase();
    final profileToStore =
        normalizedProfile == 'PROVIDER' || normalizedProfile == 'CUSTOMER'
            ? normalizedProfile!
            : 'CUSTOMER';
    await SharedPrefsHelper.setString(
      AppConstants.defaultProfile,
      profileToStore,
    );
    // Now that a token is persisted, bring the notification socket online
    // (spec §5). It would have silently no-op'd at app start without a token.
    if (Get.isRegistered<WebSocketService>()) {
      await Get.find<WebSocketService>().connectToNotifications();
    }
  }

  String _routeAfterLogin() {
    // Login always enters the main dashboard. MainController reads the stored
    // profile and users can switch between customer/provider from HomeHeader.
    return Routes.MAIN;
  }

  Future<void> loginWithPassword() async {
    if (!loginFormKey.currentState!.validate()) return;

    isPasswordLoginLoading.value = true;
    try {
      final authResp = await _authRepo.loginWithPassword(
        emailController.text.trim(),
        passwordController.text,
      );
      await _storeTokensAndNavigate(
        authResp.access,
        authResp.refresh,
        defaultProfile: authResp.defaultProfile,
      );
      Get.offAllNamed(_routeAfterLogin());
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isPasswordLoginLoading.value = false;
    }
  }

  Future<void> requestLoginOtp() async {
    if (!emailEntryFormKey.currentState!.validate()) return;

    isOtpRequestLoading.value = true;
    try {
      final contact = emailController.text.trim();
      await _authRepo.requestLoginOtp(contact);
      Get.to(
        () => OtpVerifyView(),
        arguments: {'email': contact, 'flowType': 'login'},
      );
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isOtpRequestLoading.value = false;
    }
  }

  Future<void> verifyLoginOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      Get.snackbar("Error".tr, "Please enter the complete 6-digit OTP".tr);
      return;
    }

    isOtpVerifyLoading.value = true;
    try {
      final contact = emailController.text.trim();
      final authResp = await _authRepo.verifyLoginOtp(contact, otp);
      await _storeTokensAndNavigate(
        authResp.access,
        authResp.refresh,
        defaultProfile: authResp.defaultProfile,
      );
      Get.offAllNamed(_routeAfterLogin());
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isOtpVerifyLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoginLoading.value = true;
    try {
      // TODO: Integrate with google_sign_in package to get the real accessToken
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    } finally {
      isGoogleLoginLoading.value = false;
    }
  }

  void onAppleSignIn() {
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
