import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../service/api_service.dart';
import '../../../../service/reviewed_orders.dart';
import '../../../main/controllers/main_controller.dart';
import '../controllers/order_controller.dart';

class ReviewView extends StatefulWidget {
  final int orderId;
  ReviewView({super.key, required this.orderId});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      Get.snackbar(
        AppStrings.rateExpTitle.tr,
        AppStrings.pleaseSelectRating.tr,
      );
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final orderId = widget.orderId;
    final rating = _selectedRating;
    final review = _feedbackController.text.trim();

    // ✅ Decide which side is reviewing. In provider mode OrderController
    // isn't registered (only MyJobController is) — calling it caused the
    // "OrderController not found" crash. We talk to the repository directly
    // and pick the endpoint by mode, so it never crashes either way.
    final isProvider = Get.isRegistered<MainController>() &&
        Get.find<MainController>().activePhase.value == 2;

    bool success = false;
    bool alreadyReviewed = false;
    String? errorMsg;

    try {
      final repo = Get.find<OrderRepository>();
      if (isProvider) {
        await repo.giveProviderFeedback(orderId, rating, review);
      } else {
        await repo.giveFeedback(orderId, rating, review);
      }
      success = true;
    } on ApiException catch (e) {
      // ✅ Backend enforces one review per order and replies
      // "Your feedback already submited!". Treat that as "already reviewed"
      // rather than a scary error, and remember it so the button hides.
      if (e.message.toLowerCase().contains('already')) {
        alreadyReviewed = true;
      } else {
        errorMsg = e.message;
      }
    } catch (_) {
      errorMsg = 'Failed to submit review. Please try again.';
    }

    if (success || alreadyReviewed) {
      // Persist so the feedback button stays hidden across hot reload /
      // restart, on every screen (Order list, Completed tab, ChatView).
      ReviewedOrders.mark(orderId);
      // Refresh the customer order list if it's in memory.
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().loadOrders();
      }
    }

    if (mounted) setState(() => _isSubmitting = false);

    if (errorMsg != null) {
      // Real failure — stay on the screen so the user can retry.
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    Get.back();

    if (alreadyReviewed) {
      Get.snackbar('Already reviewed'.tr, 'You have already submitted feedback for this order.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade800,
        colorText: Colors.white,
      );
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.review.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Text(
              AppStrings.rateExperience.tr,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.feedbackDesc.tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Text(
              AppStrings.rateMark.tr,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 40.sp,
                      color: index < _selectedRating
                          ? Color(0xFFFFC107) // Amber/Gold
                          : Color(0xFFE0E0E0), // Grey
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 32.h),
            Container(
              height: 150.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppStrings.shareExperienceHint.tr,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  AppStrings.submitReview.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}