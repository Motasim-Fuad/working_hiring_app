import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';

class JobStatusBadge extends StatelessWidget {
  final String status;

  const JobStatusBadge({super.key, required this.status});

  Color get _background {
    switch (status) {
      case 'PENDING':
        return Color(0xFFE5F0FF);
      case 'ACCEPT':
      case 'CONFIRM':
        return Color(0xFFF3E5F5);
      case 'IN_PROGRESS':
        return Color(0xFFFFF3E0);
      case 'COMPLETED':
        return Color(0xFFE8F5E9);
      default:
        return Color(0xFFFFF3E0);
    }
  }

  Color get _foreground {
    switch (status) {
      case 'PENDING':
        return Color(0xFF007AFF);
      case 'ACCEPT':
      case 'CONFIRM':
        return Color(0xFF8E24AA);
      case 'IN_PROGRESS':
        return Color(0xFFE65100);
      case 'COMPLETED':
        return Color(0xFF4CAF50);
      default:
        return Color(0xFFF57C00);
    }
  }

  String get _label {
    switch (status) {
      case 'PENDING':
        return 'New Request'.tr;
      case 'ACCEPT':
      case 'CONFIRM':
        return AppStrings.confirmed.tr;
      case 'IN_PROGRESS':
        return 'In Progress'.tr;
      case 'COMPLETED':
        return AppStrings.completed.tr;
      default:
        return AppStrings.pending.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _foreground,
        ),
      ),
    );
  }
}
