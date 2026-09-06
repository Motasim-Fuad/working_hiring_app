import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/order_model.dart';
import '../controllers/my_job_controller.dart';

class JobOtpVerificationView extends StatefulWidget {
  final OrderModel job;
  JobOtpVerificationView({super.key, required this.job});

  @override
  State<JobOtpVerificationView> createState() => _JobOtpVerificationViewState();
}

class _JobOtpVerificationViewState extends State<JobOtpVerificationView> {
  final MyJobController controller = Get.find<MyJobController>();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Verify Job Completion'.tr,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please enter the OTP provided by the client to mark this job as completed.'.tr,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary, height: 1.5),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45.w,
                  height: 56.h,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    onChanged: (value) => _onOtpChanged(value, index),
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                    decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                );
              }),
            ),
            SizedBox(height: 32.h),
            Center(
              child: TextButton(
                onPressed: () {
                },
                child: Text('Send OTP to Client'.tr, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ),
            ),
            Spacer(),
            CustomButton(
              text: _isSubmitting
                  ? 'Completing...'.tr
                  : 'Verify & Complete Job'.tr,
              onPressed: () async {
                if (_isSubmitting) return;
                if (_otp.length != 6) {
                  Get.snackbar(
                    'Invalid Code'.tr,
                    'Enter the 6-digit code.'.tr,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                  );
                  return;
                }

                FocusScope.of(context).unfocus();
                setState(() => _isSubmitting = true);
                final completed =
                    await controller.completeWork(widget.job.id, _otp);
                if (!mounted) return;
                setState(() => _isSubmitting = false);
                if (completed) {
                  Navigator.of(context).pop(true);
                }
              },
              height: 50.h,
              backgroundColor: Color(0xFF589C3E),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
