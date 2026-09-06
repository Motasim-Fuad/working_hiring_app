import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/availability_repository.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../service/api_service.dart';
import '../controllers/custom_offer_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../auth/sign_up/views/map_picker_view.dart';

class CreateCustomOfferView extends StatelessWidget {
  CreateCustomOfferView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register dependencies if not already
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put(CategoryRepository(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<AvailabilityRepository>()) {
      Get.put(AvailabilityRepository(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<HelperRepository>()) {
      Get.put(HelperRepository(Get.find<ApiClient>()));
    }

    final controller = Get.put(
      CustomOfferController(
        Get.find<OrderRepository>(),
        Get.find<ChatRepository>(),
        Get.find<CategoryRepository>(),
        Get.find<UserRepository>(),
        Get.find<AvailabilityRepository>(),
        Get.find<HelperRepository>(),
      ),
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox(),
        title: Text(
          "Request Form".tr,
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
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
            // Worker Profile
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: controller.workerAvatar.isNotEmpty ? NetworkImage(controller.workerAvatar) : null,
                    child: controller.workerAvatar.isEmpty ? Icon(Icons.person, color: Colors.grey) : null,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Requesting help from".tr, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                        SizedBox(height: 4.h),
                        Text(controller.workerName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildLabel("Task title"),
            SizedBox(height: 8.h),
            _buildTextField(controller: controller.taskTitleController, hint: "e.g. Assemble an IKEA Desk"),
            SizedBox(height: 16.h),

            _buildLabel("Description"),
            SizedBox(height: 8.h),
            _buildTextField(controller: controller.detailsController, hint: "Describe the work", minLines: 4, maxLines: 4),
            SizedBox(height: 16.h),

            _buildLabel("Category"),
            SizedBox(height: 8.h),
            _buildCategoryField(controller),
            SizedBox(height: 16.h),

            // Attachments
            _buildLabel("Add Photos / Files (Optional)"),
            SizedBox(height: 12.h),
            Obx(() => SizedBox(
              height: 88.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...controller.attachments.map((f) => _buildAttachmentTile(controller, f)),
                  if (controller.attachments.length < 5)
                    _buildAddAttachmentButton(controller),
                ],
              ),
            )),
            SizedBox(height: 16.h),

            _buildLabel("Date"),
            SizedBox(height: 8.h),
            _buildDateField(context, controller),
            SizedBox(height: 16.h),
            _buildLabel("Time"),
            SizedBox(height: 8.h),
            _buildTimeField(context, controller),
            SizedBox(height: 16.h),

            // Hours
            _buildLabel("How many hours?"),
            SizedBox(height: 8.h),
            _buildHoursField(controller),
            SizedBox(height: 8.h),
            _buildSlotCheckStatus(controller),
            SizedBox(height: 16.h),

            _buildLabel("Location"),
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
                   // addressText: "Lat: ${result.latitude.toStringAsFixed(4)}, Lng: ${result.longitude.toStringAsFixed(4)}",
                  );
                }
              },
              suffixIcon: Icon(Icons.location_on, color: Colors.grey),
            ),
            SizedBox(height: 24.h),

            // Budget with enforced minimum
            _buildLabel("Optional Budget"),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Color(0xFFE5E5E5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Your Budget".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Obx(() => Text(
                        'Minimum Budget'.trParams({
                          'amount':
                              '\$${controller.minBudget.toStringAsFixed(0)}',
                        }),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      )),
                      SizedBox(width: 8.w),
                      Container(
                        width: 85.w,
                        height: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Color(0xFFE5E5E5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(r"$", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6CA34D))),
                            SizedBox(width: 4.w),
                            SizedBox(
                              width: 45.w,
                              child: TextField(
                                controller: controller.budgetController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textInputAction: TextInputAction.done,
                                onEditingComplete: () =>
                                    FocusManager.instance.primaryFocus?.unfocus(),
                                onTapOutside: (_) =>
                                    FocusManager.instance.primaryFocus?.unfocus(),
                                decoration: InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    // Slider stays between the calculated minimum budget and
                    // 2x that amount. A manually typed value may exceed this
                    // range; in that case only the thumb stays at the end.
                    final sliderMax = math.max(
                      controller.minBudget + 1,
                      controller.minBudget * 2,
                    ).toDouble();
                    return SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Color(0xFF6CA34D),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.white,
                      overlayColor: Color(0xFF6CA34D).withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: controller.budget.value
                          .clamp(controller.minBudget, sliderMax)
                          .toDouble(),
                      min: controller.minBudget,
                      max: sliderMax,
                      onChanged: (val) => controller.updateBudget(val),
                    ),
                  );
                  }),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isSending.value ? null : controller.onSendOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6CA34D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: controller.isSending.value
                  ? SizedBox(
                height: 22.h,
                width: 22.h,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text("Send Request".tr, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            )),
          ),
        ),
      ),
    ),
    );
  }

  // ─── Attachment UI ──────────────────────────────────────────

  Widget _buildAttachmentTile(CustomOfferController controller, File file) {
    final isPdf = controller.isPdf(file);
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Stack(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: isPdf
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 30.sp),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    controller.fileName(file),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade700),
                  ),
                ),
              ],
            )
                : Image.file(file, fit: BoxFit.cover, width: 80.w, height: 80.h),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => controller.removeAttachment(file),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAttachmentButton(CustomOfferController controller) {
    return GestureDetector(
      onTap: () => _showAttachmentSourceSheet(controller),
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Color(0xFF6CA34D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFF6CA34D).withOpacity(0.3)),
        ),
        child: Icon(Icons.add, color: Color(0xFF6CA34D), size: 28.sp),
      ),
    );
  }

  void _showAttachmentSourceSheet(CustomOfferController controller) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 8.h),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: Color(0xFF6CA34D)),
                title: Text("Take a photo".tr),
                onTap: () {
                  Get.back();
                  controller.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.image_outlined, color: Color(0xFF6CA34D)),
                title: Text("Choose from gallery".tr),
                onTap: () {
                  Get.back();
                  controller.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                title: Text("Attach a PDF".tr),
                onTap: () {
                  Get.back();
                  controller.pickPdf();
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Existing fields ────────────────────────────────────────

  Widget _buildCategoryField(CustomOfferController controller) {
    return Obx(() {
      final selected = controller.selectedCategoryModel.value;
      final cats = controller.categories;

      return InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: cats.isEmpty
            ? null
            : () {
          Get.bottomSheet(
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12.h),
                  Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Text("Select Category".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cats.length,
                      itemBuilder: (_, i) {
                        final cat = cats[i];
                        final isSelected = cat.id == selected?.id;
                        return ListTile(
                          title: Text(
                            cat.title ?? 'Category ${cat.id}',
                          ),
                          trailing: isSelected ? Icon(Icons.check, color: Color(0xFF6CA34D)) : null,
                          onTap: () {
                            controller.selectedCategoryModel.value = cat;
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12.r)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.title ??
                      (cats.isEmpty ? 'Loading...'.tr : 'Select category'.tr),
                  style: TextStyle(fontSize: 16.sp, color: selected == null ? Color(0xFF9E9E9E) : AppColors.textPrimary),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String text) {
    return Text(text.tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xFF535763)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint.tr,
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16.sp, fontWeight: FontWeight.w400),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Color(0xFFE5E5E5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Color(0xFF6CA34D))),
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
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12.r)),
        child: Row(
          children: [
            if (leadingIcon != null) ...[leadingIcon, SizedBox(width: 8.w)],
            Expanded(
              child: Text(value ?? hint, style: TextStyle(fontSize: 16.sp, color: value == null ? Color(0xFF9E9E9E) : AppColors.textPrimary)),
            ),
            trailingIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, CustomOfferController controller) {
    return Obx(() {
      String? displayValue;
      if (controller.selectedDate.value != null) {
        displayValue = DateFormat('d MMM, yyyy').format(controller.selectedDate.value!);
      }
      return _buildDropdownLikeField(
        hint: "Select date".tr,
        value: displayValue,
        leadingIcon: SvgPicture.asset(AppImages.calendar, width: 20.sp, colorFilter: ColorFilter.mode(Color(0xFF676767), BlendMode.srcIn)),
        trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () async {
          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
          if (date != null) controller.onDateSelected(date);
        },
      );
    });
  }

  Widget _buildHoursField(CustomOfferController controller) {
    return Obx(() {
      final h = controller.workingHour.value;
      final est = controller.estimatedTotal;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownLikeField(
            hint: "Select hours".tr,
            value: 'Hours Count'.trParams({'count': '$h'}),
            leadingIcon: Icon(Icons.timelapse, size: 20.sp, color: Color(0xFF676767)),
            trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
            onTap: () => _showHoursPicker(controller),
          ),
          SizedBox(height: 6.h),
          Text(
            controller.hourlyRate > 0
                ? 'Minimum Estimate'.trParams({
                    'minimum': '${controller.minBookingHours}',
                    'estimate': est.toStringAsFixed(0),
                    'hours': '$h',
                    'rate': controller.hourlyRate.toStringAsFixed(0),
                  })
                : 'Minimum Hours'.trParams({
                    'minimum': '${controller.minBookingHours}',
                  }),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
        ],
      );
    });
  }

  Widget _buildSlotCheckStatus(CustomOfferController controller) {
    return Obx(() {
      if (controller.isCheckingSlot.value) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(children: [
            SizedBox(width: 14.sp, height: 14.sp, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8.w),
            Text("Checking availability…".tr, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          ]),
        );
      }
      final check = controller.slotCheck.value;
      if (check == null) return SizedBox.shrink();

      if (check.isAvailable) {
        return Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(color: Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10.r)),
          child: Row(children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(
                check.slot != null && check.slot!.isNotEmpty
                    ? "Available Slot".trParams({
                        'slot': check.slot!,
                      })
                    : (check.message.isNotEmpty
                        ? check.message
                        : "Slot available".tr),
                style: TextStyle(fontSize: 13.sp, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600))),
          ]),
        );
      }

      return Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(
                check.message.isNotEmpty
                    ? check.message
                    : "Not available for these hours".tr,
                style: TextStyle(fontSize: 13.sp, color: Colors.red.shade700, fontWeight: FontWeight.w600))),
          ]),
          if (check.alternatives.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text("Available start times:".tr, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
            SizedBox(height: 6.h),
            Wrap(spacing: 8.w, runSpacing: 8.h, children: check.alternatives.map((s) =>
                GestureDetector(
                  onTap: () => controller.selectSlot(s),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Color(0xFF6CA34D))),
                    child: Text(s.slot, style: TextStyle(fontSize: 11.sp, color: Color(0xFF6CA34D))),
                  ),
                )).toList()),
          ],
        ]),
      );
    });
  }

  void _showHoursPicker(CustomOfferController controller) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text("How many hours?".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: Obx(() => ListView(
                shrinkWrap: true,
                children: controller.hoursOptions.map((h) {
                  final isSelected = controller.workingHour.value == h;
                  return ListTile(
                    title: Text(
                      'Hours Count'.trParams({'count': '$h'}),
                    ),
                    subtitle: controller.hourlyRate > 0
                        ? Text("\$${(controller.hourlyRate * h).toStringAsFixed(0)}")
                        : null,
                    trailing: isSelected ? Icon(Icons.check, color: Color(0xFF6CA34D)) : null,
                    onTap: () {
                      controller.selectHours(h);
                      Get.back();
                    },
                  );
                }).toList(),
              )),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, CustomOfferController controller) {
    return Obx(() {
      final slot = controller.selectedSlot.value;
      final noDate = controller.selectedDate.value == null;
      return _buildDropdownLikeField(
        hint: (noDate
                ? "Select a date first"
                : "Select an available time")
            .tr,
        value: slot?.slot,
        leadingIcon: Icon(Icons.access_time, size: 20.sp, color: Color(0xFF676767)),
        trailingIcon: controller.isLoadingSlots.value
            ? SizedBox(
          width: 16.sp,
          height: 16.sp,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6CA34D)),
        )
            : Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () {
          if (noDate) {
            Get.snackbar("Select date".tr, "Please choose a date first.".tr);
            return;
          }
          if (controller.isLoadingSlots.value) return;
          _showSlotPicker(controller);
        },
      );
    });
  }

  void _showSlotPicker(CustomOfferController controller) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text("Available time slots".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: Obx(() {
                if (controller.isLoadingSlots.value) {
                  return Padding(
                    padding: EdgeInsets.all(24.h),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF6CA34D))),
                  );
                }
                final slots = controller.availableSlots;
                if (slots.isEmpty) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 96.h,
                      maxHeight: Get.height * 0.35,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(24.h),
                        child: Text(
                          "No available slots for this date.".tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: slots.length,
                  itemBuilder: (_, i) {
                    final s = slots[i];
                    final isSelected = controller.selectedSlot.value?.slot == s.slot;
                    return ListTile(
                      title: Text(s.slot),
                      trailing: isSelected ? Icon(Icons.check, color: Color(0xFF6CA34D)) : null,
                      onTap: () {
                        controller.selectSlot(s);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
