import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Soft grey panel that groups [ChatCardDetailRow]s.
class ChatCardDetailsPanel extends StatelessWidget {
  final List<Widget> rows;

  const ChatCardDetailsPanel({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            rows[i],
          ],
        ],
      ),
    );
  }
}
