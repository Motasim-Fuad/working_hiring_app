import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tinted callout used for statuses, waiting states, policies and quotes.
class ChatCardNotice extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final String? title;
  final bool italic;
  final bool centered;

  const ChatCardNotice({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.title,
    this.italic = false,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
        ],
        Text(
          text,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.4,
            fontWeight: italic ? FontWeight.w400 : FontWeight.w600,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: italic ? const Color(0xFF3A3A3A) : color,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: icon == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: centered
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, size: 18.sp, color: color),
                SizedBox(width: 10.w),
                centered ? Flexible(child: content) : Expanded(child: content),
              ],
            ),
    );
  }
}
