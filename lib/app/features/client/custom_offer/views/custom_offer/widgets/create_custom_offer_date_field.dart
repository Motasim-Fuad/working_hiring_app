import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_dropdown_like_field.dart';

class CreateCustomOfferDateField extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferDateField({super.key, required this.fieldController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String? displayValue;
      if (fieldController.selectedDate.value != null) {
        displayValue = DateFormat(
          'd MMM, yyyy',
        ).format(fieldController.selectedDate.value!);
      }
      return CreateCustomOfferDropdownLikeField(
        hint: "Select date".tr,
        value: displayValue,
        leadingIcon: SvgPicture.asset(
          AppImages.calendar,
          width: 20.sp,
          colorFilter: ColorFilter.mode(Color(0xFF676767), BlendMode.srcIn),
        ),
        trailingIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (date != null) fieldController.onDateSelected(date);
        },
      );
    });
  }
}
