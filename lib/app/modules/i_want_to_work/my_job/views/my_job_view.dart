// ================================================================
// FILE: my_job_view.dart (Complete - passes clientCountered correctly)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/availability_model.dart';
import '../controllers/my_job_controller.dart';
import '../widgets/my_job_card.dart';
import 'job_otp_verification_view.dart';
import '../../../../core/widgets/responsive_layout.dart';

class MyJobView extends GetView<MyJobController> {
  MyJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          toolbarHeight: 0,
          showLeading: false,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            dividerHeight: 0,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: AppStrings.allJob.tr),
              Tab(text: AppStrings.accepted.tr),
              Tab(text: AppStrings.completed.tr),
            ],
          ),
        ),
        body: ResponsiveCenter(
          maxWidth: AppResponsive.contentMaxWidth,
          padding: EdgeInsets.zero,
          child: TabBarView(
            children: [
            _buildJobList(controller.pendingJobs),
            _buildJobList(controller.acceptedJobs),
            _buildJobList(controller.completedJobs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(RxList<OrderModel> jobs) {
    return Obx(() {
      if (jobs.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.loadJobs(),
          color: Color(0xFF6CA34D),
          child: ListView(
            children: [
              SizedBox(
                height: AppResponsive.height(400, min: 240, max: 480),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        size: AppResponsive.icon(64),
                        color: Color(0xFF6CA34D).withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.beFirstToHelp.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.noRequestsRightNow.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadJobs(),
        color: Color(0xFF6CA34D),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final status = job.effectiveStatus;

            // ✅ clientCountered: true if client has countered this order
            final bool clientCountered = controller.hasClientCountered(job.id);

            return Column(
              children: [
                MyJobCard(
              job: job,
              status: status,
              clientCountered: clientCountered,
              onTap: () {},

              // PENDING → Accept / Counter / Decline logic controlled inside card
              onAccept: status == 'PENDING'
                  ? () => controller.acceptJob(job.id)
                  : null,

              onCounter: (status == 'PENDING' && !controller.hasCountered(job.id))
                  ? () => _showCounterOfferSheet(context, job)
                  : null,

              onDecline: status == 'PENDING'
                  ? () => _showDeclineDialog(context, job)
                  : null,

              // CONFIRM only → Start Work (client paid)
              onStartWork: status == 'CONFIRM' &&
                      job.pendingCancellationRequest == null
                  ? () => controller.startWork(job.id)
                  : null,

              // IN_PROGRESS → Complete Work
              onCompleteWork: status == 'IN_PROGRESS'
                  ? () => Get.to(() => JobOtpVerificationView(job: job))
                  : null,

              // Cancel: ACCEPT or CONFIRM only
              onCancel: (status == 'ACCEPT' || status == 'CONFIRM' ||
                      status == 'CANCELLATION_REQUEST' ||
                      status == 'IN_PROGRESS') &&
                      job.pendingCancellationRequest == null
                  ? () => _showCancelJobDialog(context, job)
                  : null,

              // Propose Time: CONFIRM only, once per order
              // onProposeTime: (status == 'CONFIRM' &&
              //     !controller.hasProposedTime(job.id))
              //     ? () => _showProposeNewTimeSheet(context, job)
              //     : null,

              // proposeTimeAlreadySent:
              // status == 'CONFIRM' && controller.hasProposedTime(job.id),
                ),
                if (job.pendingCancellationRequest != null)
                  _buildCancellationRequestPanel(job),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildCancellationRequestPanel(OrderModel job) {
    final request = job.pendingCancellationRequest!;
    final requestedByCustomer =
        (request.sender ?? '').toUpperCase() == 'CUSTOMER';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancellation requested'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          if ((request.message ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text('${'Reason'.tr}: ${request.message}',
                style: TextStyle(fontSize: 13.sp)),
          ],
          SizedBox(height: 12.h),
          if (requestedByCustomer)
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.cancelAcceptJob(
                      job.id, request.id, 'ACCEPT'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D)),
                  child: Text('Accept'.tr,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.cancelAcceptJob(
                      job.id, request.id, 'DECLINED'),
                  child: Text('Decline'.tr),
                ),
              ),
            ])
          else
            Text('Waiting for customer approval.'.tr),
        ],
      ),
    );
  }

  // ── Counter offer bottom sheet ──────────────────────────────────────────
  void _showCounterOfferSheet(BuildContext context, OrderModel job) {
    final priceCtrl = TextEditingController(
        text: (job.amount ?? 0).toStringAsFixed(0));
    final msgCtrl = TextEditingController();
    final budgetObs = (job.amount ?? 0.0).obs;

    priceCtrl.addListener(() {
      budgetObs.value = double.tryParse(priceCtrl.text) ?? 0.0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Counter Offer'.tr,
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 6.h),
                Text('Propose a different budget to the client.'.tr,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14.sp)),
                SizedBox(height: 24.h),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  autofocus: true,
                  style:
                  TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: r'$ ',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  final fee = budgetObs.value * 0.20;
                  final net = budgetObs.value - fee;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Platform Fee (20%):'.tr,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.sp)),
                          Text('-\$${fee.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net Amount:'.tr,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold)),
                          Text('\$${net.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  );
                }),
                SizedBox(height: 20.h),
                Text('Message'.tr,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Explain your counter offer...'.tr,
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final price = double.tryParse(priceCtrl.text) ?? 0.0;
                      final msg = msgCtrl.text.trim();
                      if (price <= 0) {
                        Get.snackbar('Error'.tr, 'Enter a valid price.'.tr,
                            backgroundColor: Colors.red.shade100);
                        return;
                      }
                      if (msg.isEmpty) {
                        Get.snackbar('Error'.tr, 'Please enter a message.'.tr,
                            backgroundColor: Colors.red.shade100);
                        return;
                      }
                      Get.back();
                      controller.sendCounterOffer(job.id, price, msg);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Send Counter'.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp)),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Decline dialog ──────────────────────────────────────────────────────
  void _showDeclineDialog(BuildContext context, OrderModel job) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Decline Request'.tr,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent)),
              SizedBox(height: 8.h),
              Text('Are you sure you want to decline this job request?'.tr,
                  style: TextStyle(
                      fontSize: 14.sp, color: AppColors.textSecondary)),
              SizedBox(height: 20.h),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason (optional)...'.tr,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: Colors.redAccent, width: 1.5)),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Back'.tr,
                          style:
                          TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.declineJob(
                          job.id,
                          reasonCtrl.text.trim().isEmpty
                              ? 'Declined by provider'
                              : reasonCtrl.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h)),
                      child: Text('Decline'.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Propose new time sheet ──────────────────────────────────────────────
  void _showProposeNewTimeSheet(BuildContext context, OrderModel job) {
    DateTime? selectedDate;
    DateSlot? selectedSlot;
    final descCtrl = TextEditingController();
    final slots = <DateSlot>[].obs;
    final isLoadingSlots = false.obs;
    final slotsError = ''.obs;

    Future<void> loadSlots(DateTime date) async {
      isLoadingSlots.value = true;
      slotsError.value = '';
      slots.clear();
      selectedSlot = null;
      try {
        final available = await controller.fetchAvailableSlots(date);
        slots.assignAll(available);
        if (slots.isEmpty) {
          slotsError.value =
          'No available slots on this date.\nPlease choose another date or update your availability in Profile.';
        }
      } catch (_) {
        slotsError.value = 'Could not load slots. Please try again.';
      } finally {
        isLoadingSlots.value = false;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setState) {
            return Container(
              constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx2).size.height * 0.85),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx2).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
                top: 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Propose New Time'.tr,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Text(
                        'Select one of your available slots. The client will Accept or Decline.'.tr,
                        style:
                        TextStyle(fontSize: 14.sp, color: Colors.grey)),
                    SizedBox(height: 24.h),

                    // Date picker
                    Text('Select Date'.tr,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                          DateTime.now().add(Duration(days: 365)),
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: ColorScheme.light(
                                  primary: Color(0xFF6CA34D),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                          await loadSlots(picked);
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                  : 'Tap to select a date',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: selectedDate != null
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                            Icon(Icons.calendar_today,
                                size: 18.sp,
                                color: Color(0xFF6CA34D)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Available time slots
                    if (selectedDate != null) ...[
                      Text('Available Time Slots'.tr,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 8.h),
                      Obx(() {
                        if (isLoadingSlots.value) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: CircularProgressIndicator(
                                  color: Color(0xFF6CA34D)),
                            ),
                          );
                        }
                        if (slotsError.value.isNotEmpty) {
                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                              border:
                              Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange.shade700,
                                    size: 18.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(slotsError.value,
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.orange.shade800)),
                                ),
                              ],
                            ),
                          );
                        }
                        if (slots.isEmpty) return SizedBox.shrink();

                        return Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: slots.map((s) {
                            final isSelected =
                                selectedSlot?.slot == s.slot;
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedSlot = s);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF6CA34D)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(0xFF6CA34D)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  s.slot,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(height: 16.h),
                    ],

                    Text('Description / Reason'.tr,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter your reason here...'.tr,
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                                color: Color(0xFF6CA34D), width: 1.5)),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx2),
                            style: OutlinedButton.styleFrom(
                              padding:
                              EdgeInsets.symmetric(vertical: 14.h),
                              side:
                              BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.r)),
                            ),
                            child: Text('Cancel'.tr,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedDate == null) {
                                Get.snackbar('Missing'.tr, 'Please select a date'.tr,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white);
                                return;
                              }
                              if (selectedSlot == null) {
                                Get.snackbar('Missing'.tr, 'Please select an available time slot'.tr,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white);
                                return;
                              }
                              if (descCtrl.text.trim().isEmpty) {
                                Get.snackbar('Missing'.tr, 'Please provide a description'.tr,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white);
                                return;
                              }
                              final dateStr =
                                  '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                              final startTime =
                              selectedSlot!.slot.split('-').first.trim();
                              Navigator.pop(ctx2);
                              controller.proposeNewTime(job.id, dateStr,
                                  startTime, descCtrl.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                              EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: Color(0xFF6CA34D),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.r)),
                              elevation: 0,
                            ),
                            child: Text('Submit'.tr,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Cancel job dialog ───────────────────────────────────────────────────
  void _showCancelJobDialog(BuildContext context, OrderModel job) {
    final reasonCtrl = TextEditingController();
    final isAgreed = false.obs;
    final isPaid = (job.paymentStatus ?? '').toUpperCase() == 'PAID';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        child: SingleChildScrollView(
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (isPaid ? 'Request Cancellation' : 'Cancel Job').tr,
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent)),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                          isPaid
                              ? 'The customer must approve this cancellation request.'
                              : 'This cancellation will result in 1 strike.',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.redAccent,
                              height: 1.5)),
                    ),
                  ],
                ),
                SizedBox(height: 13.h),
                Text(
                    isPaid
                        ? 'The order will remain active until the customer accepts your request.'
                        : 'Are you sure you want to cancel this job? Frequent cancellations may affect your profile rating.',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.5)),
                SizedBox(height: 20.h),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please write your reason here...'.tr,
                    hintStyle:
                    TextStyle(color: Colors.grey, fontSize: 14.sp),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: Colors.redAccent, width: 1.5)),
                  ),
                ),
                SizedBox(height: 16.h),
                if (!isPaid)
                  Obx(() => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: Checkbox(
                        value: isAgreed.value,
                        activeColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r)),
                        onChanged: (v) => isAgreed.value = v ?? false,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                          'I acknowledge that canceling this job will result in 1 strike.'.tr,
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              height: 1.4)),
                    ),
                  ],
                )),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'.tr,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (reasonCtrl.text.trim().isEmpty) {
                            Get.snackbar('Error'.tr, 'Please provide a reason'.tr,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (!isPaid && !isAgreed.value) {
                            Get.snackbar('Error'.tr, 'Please check the acknowledgment box'.tr,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          controller.cancelJob(job.id, reasonCtrl.text);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                            padding:
                            EdgeInsets.symmetric(vertical: 12.h)),
                        child: Text('OK'.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
