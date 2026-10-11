import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatCardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool outlined;
  final IconData? icon;

  const ChatCardButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.icon,
  }) : outlined = false;

  const ChatCardButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.icon,
  }) : outlined = true;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    );
    final padding = EdgeInsets.symmetric(horizontal: 12.w);
    const minimumSize = Size(0, 0);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18.sp), SizedBox(width: 6.w)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                shape: shape,
                padding: padding,
                minimumSize: minimumSize,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: shape,
                padding: padding,
                minimumSize: minimumSize,
              ),
              child: child,
            ),
    );
  }
}
