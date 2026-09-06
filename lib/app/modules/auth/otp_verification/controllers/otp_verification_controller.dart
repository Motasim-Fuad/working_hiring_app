import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../service/shared_prefs_helper.dart';
import '../../../../service/websocket_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_pages.dart';

class OtpVerificationController extends GetxController {
  final AuthRepository _authRepo;

  OtpVerificationController(this._authRepo);

  late final String email;
  late final String flowType; // 'login' or 'signup'

  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());

  final RxBool isLoading = false.obs;
  final RxInt countdown = 60.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    flowType = args?['flowType'] ?? 'signup';
    startTimer();
  }

  void startTimer() {
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  String _routeAfterAuth(String? defaultProfile) {
    if (defaultProfile == 'CUSTOMER' || defaultProfile == 'PROVIDER') {
      return Routes.MAIN;
    }
    return Routes.ROLE_SELECTION;
  }

  Future<void> verifyOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      Get.snackbar('Error'.tr, 'Please enter a valid 6-digit OTP'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      if (flowType == 'login') {
        final authResp = await _authRepo.verifyLoginOtp(email, otp);
        await _storeTokens(authResp.access, authResp.refresh,
            defaultProfile: authResp.defaultProfile);
        Get.offAllNamed(_routeAfterAuth(authResp.defaultProfile));
      } else {
        final authResp = await _authRepo.verifySignUp(email, otp);
        await _storeTokens(authResp.access, authResp.refresh,
            defaultProfile: authResp.defaultProfile);
        Get.offAllNamed(_routeAfterAuth(authResp.defaultProfile));
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Something went wrong. Please try again.'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (countdown.value > 0) return;

    isLoading.value = true;
    try {
      if (flowType == 'login') {
        await _authRepo.requestLoginOtp(email);
      } else {
        await _authRepo.resendSignUpOtp(email);
      }
      startTimer();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Something went wrong. Please try again.'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _storeTokens(String access, String refresh,
      {String? defaultProfile}) async {
    await SharedPrefsHelper.setString(AppConstants.token, access);
    await SharedPrefsHelper.setString(AppConstants.refreshToken, refresh);
    if (defaultProfile != null && defaultProfile.isNotEmpty) {
      await SharedPrefsHelper.setString(
          AppConstants.defaultProfile, defaultProfile);
    }
    // Bring the notification socket online now that a token exists (spec §5).
    if (Get.isRegistered<WebSocketService>()) {
      await Get.find<WebSocketService>().connectToNotifications();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
