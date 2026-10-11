import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/widgets/state/state_message_view.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return StateMessageView(
      icon: icon,
      iconColor: AppColors.primary,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }
}
