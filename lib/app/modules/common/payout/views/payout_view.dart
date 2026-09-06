import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/payout_controller.dart';

class PayoutView extends GetView<PayoutController> {
  PayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PayoutController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Payout Methods".tr,
            style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: "Payout Settings".tr),
              Tab(text: "Tax Documents".tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPayoutSettingsTab(),
            _buildTaxDocumentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutSettingsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        children: [
          Text(
            "Payout Methods".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          if (controller.payoutMethods.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                "No payout methods added yet.".tr,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...controller.payoutMethods.map((method) => Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    leading: Icon(Icons.account_balance, color: AppColors.primary),
                    title: Text(
                      method.bankName != null
                          ? "${method.bankName} ···${method.accountNumber ?? ''}"
                          : method.methodType,
                    ),
                    subtitle: Text(method.isDefault ? "Primary Method" : ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!method.isDefault)
                          TextButton(
                            onPressed: () => controller.setDefault(method.id),
                            child: Text("Set Default".tr),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => controller.removePayoutMethod(method.id),
                        ),
                      ],
                    ),
                  ),
                )),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => _showAddBankSheet(Get.context!),
            icon: Icon(Icons.add),
            label: Text("Add Bank Account".tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    });
  }

  void _showAddBankSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Bank Account".tr,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 24.h),
                _inputField("Account Holder Name", controller.accountHolderNameController),
                SizedBox(height: 16.h),
                _inputField("Bank Name", controller.bankNameController),
                SizedBox(height: 16.h),
                _inputField("Account Number", controller.accountNumberController,
                    keyboardType: TextInputType.number),
                SizedBox(height: 16.h),
                _inputField("Routing / IFSC Code", controller.ifscCodeController),
                SizedBox(height: 24.h),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSaving.value ? null : controller.addBankAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: controller.isSaving.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text("Save".tr, style: TextStyle(fontSize: 16.sp)),
                      ),
                    )),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxDocumentsTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      children: [
        Text(
          "Tax Information".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24.h),
        _buildTextField("Name"),
        SizedBox(height: 16.h),
        _buildTextField("Date submitted", hint: "MM/DD/YYYY"),
        SizedBox(height: 16.h),
        _buildTextField("Tax country/region"),
        SizedBox(height: 16.h),
        _buildTextField("Tax ID number / SIN"),
        SizedBox(height: 16.h),
        _buildTextField("Date of Birth", hint: "MM/DD/YYYY"),
        SizedBox(height: 16.h),
        _buildTextField("Country/Region of Birth"),
        SizedBox(height: 16.h),
        _buildTextField("Primary Residence Address", maxLines: 3),
        SizedBox(height: 32.h),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            elevation: 0,
          ),
          child: Text(
            "Save Tax Documents".tr,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? label,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
