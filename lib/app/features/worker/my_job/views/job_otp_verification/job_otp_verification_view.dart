import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';

part 'job_otp_verification_view_state.dart';

class JobOtpVerificationView extends StatefulWidget {
  final OrderModel job;
  const JobOtpVerificationView({super.key, required this.job});

  @override
  State<JobOtpVerificationView> createState() => _JobOtpVerificationViewState();
}
