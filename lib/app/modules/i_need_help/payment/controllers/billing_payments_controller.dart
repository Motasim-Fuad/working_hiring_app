import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../service/api_service.dart';
import '../../../../service/api_url.dart';

class PaymentMethod {
  final String id;
  final String last4;
  final String type;
  final String icon;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.last4,
    required this.type,
    required this.icon,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as String? ?? 'Card';
    return PaymentMethod(
      id: json['id'].toString(),
      last4: json['last4'] as String? ?? '****',
      type: brand,
      icon: _iconForBrand(brand),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  static String _iconForBrand(String? brand) {
    switch (brand?.toUpperCase()) {
      case 'MASTERCARD':
        return 'assets/icons/icon_mastercard.svg';
      default:
        return 'assets/icons/icon_visa.svg';
    }
  }
}

class VoucherModel {
  final String id;
  final String amount;
  final String title;
  final String code;
  final bool isUsed;

  VoucherModel({
    required this.id,
    required this.amount,
    required this.title,
    required this.code,
    this.isUsed = false,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    final discountType = json['discount_type'] as String? ?? 'FLAT';
    final value = json['value'] as String? ?? '0';
    final displayAmount = discountType == 'PERCENTAGE' ? '$value%' : '\$$value';
    return VoucherModel(
      id: json['id'].toString(),
      amount: displayAmount,
      title: '$displayAmount Discount',
      code: json['code'] as String? ?? '',
      isUsed: json['is_used'] as bool? ?? false,
    );
  }
}

class BillingPaymentsController extends GetxController {
  late final ApiClient _client;

  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;
  final RxBool isLoadingMethods = false.obs;

  final RxList<VoucherModel> availableVouchers = <VoucherModel>[].obs;
  final Rx<VoucherModel?> selectedVoucher = Rx<VoucherModel?>(null);
  final TextEditingController voucherCodeController = TextEditingController();
  final RxBool isApplyingVoucher = false.obs;

  String get _base => ApiUrl.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _client = Get.find<ApiClient>();
    loadPaymentMethods();
    loadVouchers();
  }

  Future<void> loadPaymentMethods() async {
    isLoadingMethods.value = true;
    try {
      _client.profileType = 'customer';
      final response = await _client.get(url: '$_base${ApiUrl.customerPaymentMethods}');
      final body = response.body;
      if (body is Map && body['status'] == true) {
        final list = body['data'] as List<dynamic>? ?? [];
        paymentMethods.value = list
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // keep empty on error
    } finally {
      isLoadingMethods.value = false;
    }
  }

  Future<void> loadVouchers() async {
    try {
      _client.profileType = 'customer';
      final response = await _client.get(url: '$_base${ApiUrl.myVouchers}');
      final body = response.body;
      if (body is Map && body['status'] == true) {
        final list = body['data'] as List<dynamic>? ?? [];
        availableVouchers.value = list
            .where((e) => (e as Map<String, dynamic>)['is_used'] != true)
            .map((e) => VoucherModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // keep empty on error
    }
  }

  void selectVoucher(VoucherModel voucher) {
    selectedVoucher.value = voucher;
  }

  Future<void> applyNewVoucherCode(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar("Error".tr, "Please enter a voucher code".tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isApplyingVoucher.value = true;
    try {
      _client.profileType = 'customer';
      final response = await _client.post(
        url: '$_base${ApiUrl.addVoucher}',
        body: {'voucher_code': code.trim().toUpperCase()},
      );
      final body = response.body;
      if (body is Map && body['status'] == true) {
        voucherCodeController.clear();
        await loadVouchers();
      } else {
        final msg = body is Map ? (body['message'] ?? 'Invalid voucher code.') : 'Invalid voucher code.';
        Get.snackbar("Error", msg.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to add voucher. Please try again.".tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isApplyingVoucher.value = false;
    }
  }

  Future<void> addPaymentMethod({
    required String provider,
    required String methodType,
    required String paymentToken,
    String? brand,
    String? last4,
    bool isDefault = false,
  }) async {
    try {
      _client.profileType = 'customer';
      final body = <String, dynamic>{
        'provider': provider,
        'method_type': methodType,
        'payment_token': paymentToken,
        'is_default': isDefault,
      };
      if (brand != null) body['brand'] = brand;
      if (last4 != null) body['last4'] = last4;
      final response = await _client.post(
        url: '$_base${ApiUrl.customerPaymentMethods}',
        body: body,
      );
      final respBody = response.body as Map?;
      if (respBody != null && respBody['status'] == true) {
        await loadPaymentMethods();
      } else {
        final msg = (respBody?['message'] ?? 'Failed to add payment method.').toString();
        Get.snackbar("Error", msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to add payment method. Please try again.".tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editPaymentMethod(String id, Map<String, dynamic> updates) async {
    try {
      _client.profileType = 'customer';
      final response = await _client.patch(
        url: '$_base${ApiUrl.customerPaymentMethods}$id/',
        body: updates,
      );
      final body = response.body;
      if (body is Map && body['status'] == true) {
        await loadPaymentMethods();
      } else {
        final msg = body is Map ? (body['message'] ?? 'Failed to update payment method.') : 'Failed to update payment method.';
        Get.snackbar("Error", msg.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to update payment method.".tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    try {
      _client.profileType = 'customer';
      await _client.post(
        url: '$_base${ApiUrl.customerPaymentMethods}$id/set-default/',
        body: {},
      );
      await loadPaymentMethods();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to set default payment method.".tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  final RxBool isApplyingVoucherPreview = false.obs;

  Future<Map<String, dynamic>?> applyVoucherPreview(String code, String orderAmount) async {
    isApplyingVoucherPreview.value = true;
    try {
      _client.profileType = 'customer';
      final response = await _client.post(
        url: '$_base${ApiUrl.applyVoucher}',
        body: {'code': code.trim().toUpperCase(), 'order_amount': orderAmount},
      );
      final body = response.body;
      if (body is Map && body['status'] == true) {
        return body.cast<String, dynamic>();
      } else {
        final msg = body is Map ? (body['message'] ?? 'Invalid voucher.') : 'Invalid voucher.';
        Get.snackbar("Error", msg.toString(), snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to apply voucher.".tr,
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isApplyingVoucherPreview.value = false;
    }
  }

  void showEditPaymentMethodDialog(PaymentMethod method) {
    final isDefaultCtrl = method.isDefault.obs;
    Get.defaultDialog(
      title: 'Edit Payment Method'.tr,
      content: Obx(
        () => CheckboxListTile(
          title: Text('Set as default'.tr),
          value: isDefaultCtrl.value,
          onChanged: (v) => isDefaultCtrl.value = v ?? false,
        ),
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        editPaymentMethod(method.id, {'is_default': isDefaultCtrl.value});
      },
    );
  }

  void removePaymentMethod(String id) {
    Get.defaultDialog(
      title: 'Remove Payment Method'.tr,
      middleText: 'Are you sure you want to remove this payment method?'.tr,
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          _client.profileType = 'customer';
          await _client.delete(
            url: '$_base${ApiUrl.customerPaymentMethods}$id/',
            isBasic: false,
            code: 200,
          );
          await loadPaymentMethods();
        } catch (_) {
          paymentMethods.removeWhere((e) => e.id == id);
        }
      },
    );
  }

  @override
  void onClose() {
    voucherCodeController.dispose();
    super.onClose();
  }
}
