import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'responsive_layout.dart';

class ContextualWarningBanner extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  const ContextualWarningBanner({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFFFB6B6), // Light red/pink
    this.textColor = Colors.white,
    this.icon = Icons.error_outline,
    this.iconColor = const Color(0xFFFF5252),
  });

  @override
  State<ContextualWarningBanner> createState() => _ContextualWarningBannerState();
}

class _ContextualWarningBannerState extends State<ContextualWarningBanner> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          height: _isVisible ? null : 0,
          margin: _isVisible
              ? EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h)
              : EdgeInsets.zero,
          padding: _isVisible
              ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: _isVisible
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon, color: widget.iconColor, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: AppResponsive.font(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
