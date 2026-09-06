import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../main/controllers/main_controller.dart';
import '../controllers/create_task_controller.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../auth/sign_up/views/map_picker_view.dart';


class CreateTaskView extends GetView<CreateTaskController> {
  CreateTaskView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox(),
        title: Text(
          "Find Helpers".tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Color(0xFFCBEFB6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security,
                          color: Color(0xFF2E7D32), size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(AppStrings.securePayment.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32))),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(AppStrings.paymentReleasedCompletion.tr,
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.black87)),
                  Text(AppStrings.beSpecificDetails.tr,
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.black87)),
                ],
              ),
            ),
            _buildLabel("Category"),
            SizedBox(height: 8.h),
            _buildCategoryField(context),

            SizedBox(height: 16.h),

            _buildLabel("Sub-Category"),
            SizedBox(height: 8.h),
            Obx(() => _buildDropdownLikeField(
                  hint: "Choose sub-category",
                  value: controller.selectedSubCategory.value.isEmpty
                      ? null
                      : controller.selectedSubCategory.value,
                  trailingIcon: Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF9E9E9E)),
                  onTap: () => _showSubCategorySheet(context),
                )),

            SizedBox(height: 16.h),

            _buildLabel("Task title"),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.taskTitleController,
              hint: "e.g. Assemble an IKEA Desk",
            ),

            SizedBox(height: 16.h),

            _buildLabel("Address / Area"),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.addressController,
              hint: "Tap to pick location on map",
              readOnly: true,
              onTap: () async {
                final result = await Get.to(() => MapPickerView());
                if (result != null && result is LatLng) {
                  controller.setSelectedLocation(
                    result.latitude,
                    result.longitude,
                    addressText:
                    "Lat: ${result.latitude.toStringAsFixed(4)}, Lng: ${result.longitude.toStringAsFixed(4)}",
                  );
                }
              },
              suffixIcon: Icon(Icons.location_on, color: Colors.grey),
            ),

            if (Get.find<MainController>().activePhase.value != 2) ...[
              SizedBox(height: 16.h),
              _buildLabel("Select date".tr),
              SizedBox(height: 8.h),
              _buildDateField(context),

              SizedBox(height: 16.h),
              _buildLabel("Select time"),
              SizedBox(height: 8.h),
              _buildTimeField(context),
            ],

            SizedBox(height: 16.h),

            _buildLabel("Details"),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.detailsController,
              hint: "Describe the work",
              minLines: 5,
              maxLines: 5,
            ),

            SizedBox(height: 16.h),

            _buildLabel("Budget"),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.budgetController,
              hint: "80-100",
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixText: '\$ ',
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            ),
            SizedBox(height: 4.h),
            Text(
              "+ service fee".tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Get.find<MainController>().activePhase.value == 2 ? SizedBox.shrink() : SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isSubmitting.value ? null : controller.onPostTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6CA34D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(width: 24.w, height: 24.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      "Find Helpers".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final int hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Color(0xFF535763),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        prefixStyle: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFF6CA34D)),
        ),
      ),
    );
  }

  Widget _buildDropdownLikeField({
    required String hint,
    required Widget trailingIcon,
    Widget? leadingIcon,
    VoidCallback? onTap,
    String? value,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: value == null ? Color(0xFF9E9E9E) : AppColors.textPrimary,
                ),
              ),
            ),
            trailingIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Obx(() {
      Widget? leadingIcon;
      String? displayValue;

      if (controller.selectedCategory.value.isNotEmpty && controller.categories.isNotEmpty) {
        final cat = controller.categories.firstWhere(
          (e) => (e.title ?? '') == controller.selectedCategory.value,
          orElse: () => controller.categories.first,
        );
        displayValue = cat.title ?? '';
        if (cat.icon != null && cat.icon!.isNotEmpty) {
          leadingIcon = SvgPicture.asset(cat.icon!, width: 20.sp, height: 20.sp);
        }
      }

      return _buildDropdownLikeField(
        hint: "Choose category",
        value: displayValue,
        leadingIcon: leadingIcon,
        trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () => _showCategorySheet(context),
      );
    });
  }

  Widget _buildDateField(BuildContext context) {
    return Obx(() {
      String? displayValue;
      if (controller.selectedDate.value != null) {
        displayValue = DateFormat('d MMM, yyyy').format(controller.selectedDate.value!);
      }

      return _buildDropdownLikeField(
        hint: "Select date".tr,
        value: displayValue,
        leadingIcon: SvgPicture.asset(
          AppImages.calendar,
          width: 20.sp,
          colorFilter: ColorFilter.mode(
            Color(0xFF676767),
            BlendMode.srcIn,
          ),
        ),
        trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (date != null) controller.selectedDate.value = date;
        },
      );
    });
  }

  Widget _buildTimeField(BuildContext context) {
    return Obx(() {
      String? displayValue;
      if (controller.selectedTime.value != null) {
        displayValue = _formatTime(controller.selectedTime.value!);
      }

      return _buildDropdownLikeField(
        hint: "Select time",
        value: displayValue,
        leadingIcon: SvgPicture.asset(
          AppImages.time,
          width: 20.sp,
          colorFilter: ColorFilter.mode(
            Color(0xFF676767),
            BlendMode.srcIn,
          ),
        ),
        trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) controller.selectedTime.value = time;
        },
      );
    });
  }

  void _showCategorySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView(
          shrinkWrap: true,
          children: controller.categories
              .map(
                (cat) => ListTile(
                  leading: cat.icon != null && cat.icon!.isNotEmpty
                      ? SvgPicture.asset(cat.icon!, width: 24.sp)
                      : null,
                  title: Text(cat.title ?? ''),
                  onTap: () => controller.selectCategory(cat.title ?? '', cat.id),
                ),
              )
              .toList(),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSubCategorySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView(
          shrinkWrap: true,
          children: controller.subCategories
              .map(
                (subCat) => ListTile(
                  title: Text(subCat.title ?? ''),
                  onTap: () => controller.selectSubCategory(subCat.title ?? '', subCat.id),
                ),
              )
              .toList(),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
