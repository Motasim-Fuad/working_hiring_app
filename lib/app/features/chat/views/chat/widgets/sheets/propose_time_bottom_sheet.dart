import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/availability_model.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

// Propose New Time bottom sheet (Provider only).
// Called from PaymentCompletedCardWidget's "Propose New Time" button,
// which always passes widget.msg.orderId — the exact orderId that
// specific card represents. No scanning chat history, no guessing.
void showProposeTimeBottomSheet(
  BuildContext context,
  int orderId,
  MessageController controller,
) {
  final selectedDate = Rxn<DateTime>();
  final selectedSlot = Rxn<String>();
  final descCtrl = TextEditingController();
  final slots = <DateSlot>[].obs;
  final isLoadingSlots = false.obs;
  final slotsError = ''.obs;

  Future<void> loadSlots(DateTime date) async {
    isLoadingSlots.value = true;
    slotsError.value = '';
    slots.clear();
    selectedSlot.value = null;

    try {
      final available = await controller.fetchAvailableSlots(date);
      slots.assignAll(available);
      if (slots.isEmpty) {
        slotsError.value =
            'No available slots on this date.\nPlease choose another date or update your availability in Profile.'
                .tr;
      }
    } catch (e) {
      slotsError.value = 'Could not load slots. Please try again.'.tr;
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Get.bottomSheet(
    isScrollControlled: true,
    Obx(
      () => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Text(
                  'Propose New Time'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Select one of your available slots. Client will Accept or Decline.'
                      .tr,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                SizedBox(height: 20.h),

                Text(
                  'Date'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: Get.context!,
                      initialDate:
                          selectedDate.value ??
                          DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (c, child) => Theme(
                        data: Theme.of(c).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF6CA34D),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                      await loadSlots(picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate.value != null
                              ? '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}'
                              : 'Tap to select a date'.tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: selectedDate.value != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18.sp,
                          color: Color(0xFF6CA34D),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                if (selectedDate.value != null) ...[
                  Text(
                    'Available Time Slots'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Builder(
                    builder: (_) {
                      if (isLoadingSlots.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: CircularProgressIndicator(
                              color: Color(0xFF6CA34D),
                            ),
                          ),
                        );
                      }
                      if (slotsError.value.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  slotsError.value,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (slots.isEmpty) return SizedBox.shrink();

                      return Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: slots.map((s) {
                          // "09:00 AM - 10:00 AM" -> "09:00 AM"
                          final startTime = s.slot.split('-').first.trim();
                          final isSelected = selectedSlot.value == startTime;
                          return GestureDetector(
                            onTap: () => selectedSlot.value = startTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF6CA34D)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF6CA34D)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                startTime,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                ],

                Text(
                  'Reason'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Why do you need to change the time?'.tr,
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Color(0xFF6CA34D),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedDate.value == null) {
                        Get.snackbar(
                          'Missing'.tr,
                          'Please select a date.'.tr,
                          backgroundColor: Colors.red.shade100,
                        );
                        return;
                      }
                      if (selectedSlot.value == null) {
                        Get.snackbar(
                          'Missing'.tr,
                          'Please select an available time slot.'.tr,
                          backgroundColor: Colors.red.shade100,
                        );
                        return;
                      }
                      if (descCtrl.text.trim().isEmpty) {
                        Get.snackbar(
                          'Missing'.tr,
                          'Please provide a reason.'.tr,
                          backgroundColor: Colors.red.shade100,
                        );
                        return;
                      }

                      final dateStr =
                          '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';

                      try {
                        final success = await controller
                            .proposeNewTimeFromOrder(
                              orderId,
                              dateStr,
                              selectedSlot.value!,
                              descCtrl.text.trim(),
                            );
                        if (success) {
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error'.tr,
                          'Propose failed'.trParams({'error': e.toString()}),
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Propose New Time'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
