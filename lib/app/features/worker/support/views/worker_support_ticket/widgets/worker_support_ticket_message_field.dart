import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkerSupportTicketMessageField extends StatelessWidget {
  final TextEditingController fieldController;

  const WorkerSupportTicketMessageField({
    super.key,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: fieldController,
        maxLines: 8,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}
