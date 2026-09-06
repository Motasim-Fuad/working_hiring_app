import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../service/api_service.dart';
import '../../../../service/api_url.dart';

class PayoutMethod {
  final int id;
  final String methodType;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final bool isDefault;
  final bool isVerified;

  PayoutMethod({
    required this.id,
    required this.methodType,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.isDefault = false,
    this.isVerified = false,
  });

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(
      id: json['id'] as int,
      methodType: json['method_type'] as String? ?? 'BANK',
      accountHolderName: json['account_holder_name'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class PayoutController extends GetxController {
  late final ApiClient _client;

  final RxList<PayoutMethod> payoutMethods = <PayoutMethod>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final TextEditingController accountHolderNameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  String get _base => ApiUrl.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _client = Get.find<ApiClient>();
    loadPayoutMethods();
  }

  Future<void> loadPayoutMethods() async {
    isLoading.value = true;
    try {
      _client.profileType = 'provider';
      final response = await _client.get(url: '$_base${ApiUrl.providerPayoutMethods}');
      final body = response.body;
      if (body is Map && body['status'] == true) {
        final list = body['data'] as List<dynamic>? ?? [];
        payoutMethods.value = list
            .map((e) => PayoutMethod.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // keep empty
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBankAccount() async {
    final holder = accountHolderNameController.text.trim();
    final bank = bankNameController.text.trim();
    final account = accountNumberController.text.trim();
    final ifsc = ifscCodeController.text.trim();

    if (account.isEmpty || ifsc.isEmpty) {
      Get.snackbar("Error".tr, "Account number and routing code are required".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      _client.profileType = 'provider';
      final response = await _client.post(
        url: '$_base${ApiUrl.providerPayoutMethods}',
        body: {
          'method_type': 'BANK',
          'account_holder_name': holder,
          'bank_name': bank,
          'account_number': account,
          'ifsc_code': ifsc,
          'is_default': payoutMethods.isEmpty,
        },
      );
      final body = response.body;
      if (body is Map && body['status'] == true) {
        _clearForm();
        await loadPayoutMethods();
        Get.back();
      } else {
        final msg = body is Map ? (body['message'] ?? 'Failed to add account.') : 'Failed to add account.';
        Get.snackbar("Error", msg.toString());
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to add account. Please try again.".tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setDefault(int id) async {
    try {
      _client.profileType = 'provider';
      await _client.post(
        url: '$_base${ApiUrl.providerPayoutMethods}$id/set-default/',
        body: {},
      );
      await loadPayoutMethods();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    }
  }

  Future<void> editPayoutMethod(int id, Map<String, dynamic> updates) async {
    isSaving.value = true;
    try {
      _client.profileType = 'provider';
      final response = await _client.patch(
        url: '$_base${ApiUrl.providerPayoutMethods}$id/',
        body: updates,
      );
      final body = response.body;
      if (body is Map && body['status'] == true) {
        await loadPayoutMethods();
      } else {
        final msg = body is Map ? (body['message'] ?? 'Failed to update.') : 'Failed to update.';
        Get.snackbar("Error", msg.toString());
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to update payout method. Please try again.".tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removePayoutMethod(int id) async {
    Get.defaultDialog(
      title: 'Remove Payout Method'.tr,
      middleText: 'Are you sure you want to remove this payout method?'.tr,
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          _client.profileType = 'provider';
          await _client.delete(
            url: '$_base${ApiUrl.providerPayoutMethods}$id/',
            isBasic: false,
            code: 200,
          );
          await loadPayoutMethods();
        } catch (_) {
          payoutMethods.removeWhere((e) => e.id == id);
        }
      },
    );
  }

  void _clearForm() {
    accountHolderNameController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    ifscCodeController.clear();
  }

  @override
  void onClose() {
    accountHolderNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    super.onClose();
  }
}
