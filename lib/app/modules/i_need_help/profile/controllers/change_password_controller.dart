import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepo;

  ChangePasswordController(this._authRepo);

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var obscureCurrent = true.obs;
  var obscureNew = true.obs;
  var obscureConfirm = true.obs;

  void toggleCurrent() => obscureCurrent.value = !obscureCurrent.value;
  void toggleNew() => obscureNew.value = !obscureNew.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> changePassword() async {
    final current = currentPasswordController.text;
    final newPwd = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (newPwd != confirm) {
      Get.snackbar("Error".tr, "New passwords do not match".tr);
      return;
    }
    try {
      await _authRepo.changePassword(current, newPwd, confirm);
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Something went wrong. Please try again.".tr);
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
