import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateCustomOfferLabel extends StatelessWidget {
  final String text;

  const CreateCustomOfferLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Color(0xFF535763),
      ),
    );
  }
}
