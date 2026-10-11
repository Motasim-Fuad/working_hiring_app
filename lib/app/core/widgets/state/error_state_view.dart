import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/state/state_message_view.dart';

class ErrorStateView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorStateView({super.key, this.title, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StateMessageView(
      icon: Icons.wifi_tethering_error_rounded,
      iconColor: AppColors.error,
      title: title ?? 'Something went wrong'.tr,
      message: message,
      actionText: onRetry == null ? null : AppStrings.tryAgain.tr,
      onAction: onRetry,
    );
  }
}
