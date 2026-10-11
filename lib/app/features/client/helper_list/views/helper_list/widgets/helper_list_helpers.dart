import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';

PopupMenuItem<String> buildSortMenuItem(String value, IconData icon) {
  final controller = Get.find<HelperListController>();
  return PopupMenuItem<String>(
    value: value,
    child: Obx(() {
      final isSelected = controller.selectedSort.value == value;
      return Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isSelected ? Color(0xFF6CA34D) : Colors.grey.shade500,
          ),
          SizedBox(width: 10.w),
          Text(
            value.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? Color(0xFF6CA34D) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      );
    }),
  );
}
