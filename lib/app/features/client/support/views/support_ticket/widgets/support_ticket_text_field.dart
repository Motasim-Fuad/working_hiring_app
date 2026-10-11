import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupportTicketTextField extends StatelessWidget {
  final TextEditingController fieldController;
  final String? hint;

  const SupportTicketTextField({
    super.key,
    required this.fieldController,
    this.hint,
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
