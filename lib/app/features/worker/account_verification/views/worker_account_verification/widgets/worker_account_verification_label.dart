import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkerAccountVerificationLabel extends StatelessWidget {
  final String text;

  const WorkerAccountVerificationLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Color(0xFF424242),
      ),
    );
  }
}
