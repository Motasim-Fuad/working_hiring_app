import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/data/models/saved_helper_model.dart';

class SavedHelpersSavedCard extends GetView<HelperListController> {
  final SavedHelperEntry entry;
  final void Function(SavedHelperEntry) onRemove;

  const SavedHelpersSavedCard({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final helper = entry.helper;
    return GestureDetector(
      onTap: () => controller.navigateToProfile(helper),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: helper.avatarUrl.isNotEmpty
                      ? NetworkImage(helper.avatarUrl)
                      : null,
                  child: helper.avatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey, size: 26.sp)
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helper.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            helper.rating?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Tasks Count Parenthesized'.trParams({
                              'count': '${helper.totalTasks ?? 0}',
                            }),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      if (helper.location != null)
                        Text(
                          helper.location!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 24.sp,
                  ),
                  onPressed: () {
                    onRemove(entry);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (helper.categories != null)
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: helper.categories!.map((cat) {
                  return Chip(
                    label: Text(cat, style: TextStyle(fontSize: 12.sp)),
                    backgroundColor: Color(0xFFE8F8F5),
                    labelStyle: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12.sp,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            if (helper.hourlyRate != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Rate Per Hour'.trParams({
                    'amount': '\$${helper.hourlyRate!.toInt()}',
                  }),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6CA34D),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
