import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/helper_list_helpers.dart';

class HelperListSortSection extends GetView<HelperListController> {
  const HelperListSortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                'Helpers Found'.trParams({
                  'count': '${controller.displayedHelpers.length}',
                }),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              offset: Offset(0, 35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 4,
              color: Colors.white,
              onSelected: (val) {
                controller.selectedSort.value = val;
                controller.applySort();
              },
              itemBuilder: (context) => [
                buildSortMenuItem("Rating (High-Low)", Icons.star_rounded),
                buildSortMenuItem(
                  "Price (Low-High)",
                  Icons.attach_money_rounded,
                ),
                buildSortMenuItem(
                  "Distance (Nearest)",
                  Icons.location_on_rounded,
                ),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Text(
                        controller.selectedSort.value.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF6CA34D),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6CA34D),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
