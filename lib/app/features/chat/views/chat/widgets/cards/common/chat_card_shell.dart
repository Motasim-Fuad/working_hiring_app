import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

/// Shared frame for every order card in the chat: accent strip, icon badge,
/// overline label, optional trailing pill and padded body.
class ChatCardShell extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Widget child;
  final Alignment alignment;

  const ChatCardShell({
    super.key,
    required this.accent,
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * 0.9).clamp(280.0, 760.0);
    final radius = BorderRadius.circular(20.r);

    return Align(
      alignment: alignment,
      child: Container(
        width: width.toDouble(),
        margin: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.35)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                child: Row(
                  children: [
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(icon, size: 18.sp, color: accent),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(16.w), child: child),
            ],
          ),
        ),
      ),
    );
  }
}
