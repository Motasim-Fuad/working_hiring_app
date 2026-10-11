import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/models/helper_profile_model.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';

String buildLocationString(HelperProfileModel? profile) {
  if (profile == null) return '';
  final loc = profile.officeLocation;
  if (loc == null) return '';
  final parts = [
    loc.addressLine,
    loc.city,
  ].where((s) => s != null && s.isNotEmpty).toList();
  return parts.isNotEmpty ? parts.join(', ') : '';
}

ImageProvider? getAvatarImage(String? logoUrl) {
  if (logoUrl != null && logoUrl.isNotEmpty) {
    return NetworkImage(logoUrl);
  }
  final workerCtrl = Get.find<WorkerProfileController>();
  return workerCtrl.displayPhoto;
}

String formatDate(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return '';
  }
}
