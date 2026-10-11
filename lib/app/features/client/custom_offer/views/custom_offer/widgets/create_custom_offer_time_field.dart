import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_dropdown_like_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/show_slot_picker.dart';

class CreateCustomOfferTimeField extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferTimeField({super.key, required this.fieldController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slot = fieldController.selectedSlot.value;
      final noDate = fieldController.selectedDate.value == null;
      return CreateCustomOfferDropdownLikeField(
        hint: (noDate ? "Select a date first" : "Select an available time").tr,
        value: slot?.slot,
        leadingIcon: Icon(
          Icons.access_time,
          size: 20.sp,
          color: Color(0xFF676767),
        ),
        trailingIcon: fieldController.isLoadingSlots.value
            ? SizedBox(
                width: 16.sp,
                height: 16.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6CA34D),
                ),
              )
            : Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () {
          if (noDate) {
            Get.snackbar("Select date".tr, "Please choose a date first.".tr);
            return;
          }
          if (fieldController.isLoadingSlots.value) return;
          showSlotPicker(fieldController);
        },
      );
    });
  }
}
