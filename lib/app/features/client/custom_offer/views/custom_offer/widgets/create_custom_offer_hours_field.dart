import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/create_custom_offer_dropdown_like_field.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/widgets/show_hours_picker.dart';

class CreateCustomOfferHoursField extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferHoursField({super.key, required this.fieldController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final h = fieldController.workingHour.value;
      final est = fieldController.estimatedTotal;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateCustomOfferDropdownLikeField(
            hint: "Select hours".tr,
            value: 'Hours Count'.trParams({'count': '$h'}),
            leadingIcon: Icon(
              Icons.timelapse,
              size: 20.sp,
              color: Color(0xFF676767),
            ),
            trailingIcon: Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF9E9E9E),
            ),
            onTap: () => showHoursPicker(fieldController),
          ),
          SizedBox(height: 6.h),
          Text(
            fieldController.hourlyRate > 0
                ? 'Minimum Estimate'.trParams({
                    'minimum': '${fieldController.minBookingHours}',
                    'estimate': est.toStringAsFixed(0),
                    'hours': '$h',
                    'rate': fieldController.hourlyRate.toStringAsFixed(0),
                  })
                : 'Minimum Hours'.trParams({
                    'minimum': '${fieldController.minBookingHours}',
                  }),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
        ],
      );
    });
  }
}
