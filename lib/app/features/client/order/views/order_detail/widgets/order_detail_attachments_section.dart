import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderDetailAttachmentsSection extends StatelessWidget {
  final List<String> attachments;

  const OrderDetailAttachmentsSection({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments'.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  attachments[index],
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 100.w,
                    height: 100.h,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
