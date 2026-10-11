import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:working_hiring/app/features/auth/sign_up/views/map_picker/map_picker_view.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_attachment_tile.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_add_attachment_button.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_category_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_label.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_text_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_date_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_hours_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_slot_check_status.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_time_field.dart';

class CreateCustomOfferView extends StatelessWidget {
  const CreateCustomOfferView({super.key});

  @override
  Widget build(BuildContext context) {
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
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: controller.workerAvatar.isNotEmpty
                          ? NetworkImage(controller.workerAvatar)
                          : null,
                      child: controller.workerAvatar.isEmpty
                          ? Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Requesting help from".tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            controller.workerName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              CreateCustomOfferLabel(text: "Task title"),
              SizedBox(height: 8.h),
              CreateCustomOfferTextField(
                fieldController: controller.taskTitleController,
                hint: "e.g. Assemble an IKEA Desk",
              ),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "Description"),
              SizedBox(height: 8.h),
              CreateCustomOfferTextField(
                fieldController: controller.detailsController,
                hint: "Describe the work",
                minLines: 4,
                maxLines: 4,
              ),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "Category"),
              SizedBox(height: 8.h),
              CreateCustomOfferCategoryField(fieldController: controller),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "Add Photos / Files (Optional)"),
              SizedBox(height: 12.h),
              Obx(
                () => SizedBox(
                  height: 88.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...controller.attachments.map(
                        (f) => CreateCustomOfferAttachmentTile(
                          fieldController: controller,
                          file: f,
                        ),
                      ),
                      if (controller.attachments.length < 5)
                        CreateCustomOfferAddAttachmentButton(
                          fieldController: controller,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "Date"),
              SizedBox(height: 8.h),
              CreateCustomOfferDateField(fieldController: controller),
              SizedBox(height: 16.h),
              CreateCustomOfferLabel(text: "Time"),
              SizedBox(height: 8.h),
              CreateCustomOfferTimeField(fieldController: controller),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "How many hours?"),
              SizedBox(height: 8.h),
              CreateCustomOfferHoursField(fieldController: controller),
              SizedBox(height: 8.h),
              CreateCustomOfferSlotCheckStatus(fieldController: controller),
              SizedBox(height: 16.h),

              CreateCustomOfferLabel(text: "Location"),
              SizedBox(height: 8.h),
              CreateCustomOfferTextField(
                fieldController: controller.addressController,
                hint: "Tap to pick location on map",
                readOnly: true,
                onTap: () async {
                  final result = await Get.to(() => MapPickerView());
                  if (result != null && result is LatLng) {
                    controller.setSelectedLocation(
                      result.latitude,
                      result.longitude,
                    );
                  }
                },
                suffixIcon: Icon(Icons.location_on, color: Colors.grey),
              ),
              SizedBox(height: 24.h),

              CreateCustomOfferLabel(text: "Optional Budget"),
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
                        Text(
                          "Your Budget".tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Obx(
                          () => Text(
                            'Minimum Budget'.trParams({
                              'amount':
                                  '\$${controller.minBudget.toStringAsFixed(0)}',
                            }),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
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
                              Text(
                                r"$",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6CA34D),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              SizedBox(
                                width: 45.w,
                                child: TextField(
                                  controller: controller.budgetController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: () => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
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
                      final sliderMax = math
                          .max(
                            controller.minBudget + 1,
                            controller.minBudget * 2,
                          )
                          .toDouble();
                      return SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Color(0xFF6CA34D),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: Colors.white,
                          overlayColor: Color(
                            0xFF6CA34D,
                          ).withValues(alpha: 0.2),
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
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isSending.value
                      ? null
                      : controller.onSendOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSending.value
                      ? SizedBox(
                          height: 22.h,
                          width: 22.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Send Request".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
