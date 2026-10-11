import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

part 'contextual_warning_banner_state.dart';

class ContextualWarningBanner extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  const ContextualWarningBanner({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFFFB6B6),
    this.textColor = Colors.white,
    this.icon = Icons.error_outline,
    this.iconColor = const Color(0xFFFF5252),
  });

  @override
  State<ContextualWarningBanner> createState() =>
      _ContextualWarningBannerState();
}
