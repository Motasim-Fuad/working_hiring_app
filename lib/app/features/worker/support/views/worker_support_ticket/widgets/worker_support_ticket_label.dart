import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkerSupportTicketLabel extends StatelessWidget {
  final String text;
  final bool withInfo;

  const WorkerSupportTicketLabel({
    super.key,
    required this.text,
    this.withInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (withInfo) ...[
          SizedBox(width: 6.w),
          Icon(Icons.info, color: Color(0xFFBDBDBD), size: 16.sp),
        ],
      ],
    );
  }
}
