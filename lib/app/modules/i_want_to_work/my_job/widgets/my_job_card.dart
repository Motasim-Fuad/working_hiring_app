import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/order_model.dart';
import '../../../i_need_help/order/views/review_view.dart';
import '../controllers/my_job_controller.dart';

class MyJobCard extends StatelessWidget {
  final OrderModel job;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onCounter;
  final VoidCallback? onDecline;
  final VoidCallback? onStartWork;
  final VoidCallback? onCompleteWork;
  final VoidCallback? onCancel;
  final VoidCallback? onProposeTime;
  final bool proposeTimeAlreadySent;
  final String status;
  // ✅ clientCountered – true মানে ক্লায়েন্ট কাউন্টার দিয়েছে
  final bool clientCountered;

  MyJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onAccept,
    this.onCounter,
    this.onDecline,
    this.onStartWork,
    this.onCompleteWork,
    this.onCancel,
    this.onProposeTime,
    this.proposeTimeAlreadySent = false,
    required this.status,
    this.clientCountered = false,
  });

  Color _getStatusColor() {
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

  Color _getStatusTextColor() {
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

  String _getStatusText() {
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: title + status badge ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusTextColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // ── Category ──────────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(job.categoryName ?? '',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                  ],
                ),
                SizedBox(height: 10),

                // ── Posted by ─────────────────────────────────────────────
                Row(
                  children: [
                    Text(AppStrings.postedBy.tr,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    SizedBox(width: 4),
                    Text(
                      _customerLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                SizedBox(height: 6),

                // ── Address + date/time + amount ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.pinkAccent,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  job.address ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  softWrap: true,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFF6CA34D),
                              ),
                              SizedBox(width: 8),
                              Text(
                                job.workingDate ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF6CA34D),
                              ),
                              SizedBox(width: 6),
                              Text(
                                job.workingStartTime ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        '\$${(job.amount ?? 0).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Action buttons by status ──────────────────────────────

                // PENDING → negotiation logic
                if (status == 'PENDING') ...[
                  SizedBox(height: 16),

                  // Provider has already countered → no counter button
                  // We detect this by checking if onCounter is null.
                  // Also check clientCountered to decide whether to show Accept/Decline or waiting message.

                  if (onCounter == null) ...[
                    // Provider already sent a counter
                    if (clientCountered) ...[
                      // Client also countered → provider now sees Accept + Decline (no Counter)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Color(0xFF6CA34D),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Accept'.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (onDecline != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onDecline,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                  EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.redAccent),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Decline'.tr,
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ] else ...[
                      // Client hasn't countered yet → show waiting message
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top,
                                size: 16, color: Colors.orange.shade700),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Counter sent — waiting for client response.'.tr,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    // Provider has NOT countered yet
                    // Show Accept, Counter, Decline (full set)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Color(0xFF6CA34D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Accept'.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (onDecline != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onDecline,
                              style: OutlinedButton.styleFrom(
                                padding:
                                EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Decline'.tr,
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCounter,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Color(0xFF6CA34D)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Counter'.tr,
                                style: TextStyle(
                                    color: Color(0xFF6CA34D),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                // ACCEPT → provider accepted, client hasn't paid yet
                if (status == 'ACCEPT') ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_top,
                            color: Colors.amber.shade800, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Waiting for client payment'.tr,
                          style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (onCancel != null) ...[
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel'.tr,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],

                // CONFIRM → client paid → Cancel + Start Work + Propose Time
                if (status == 'CONFIRM') ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      if (onCancel != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Cancel'.tr,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (onStartWork != null) ...[
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onStartWork,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Color(0xFF6CA34D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text('Start Work'.tr,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // if (onProposeTime != null) ...[
                  //   SizedBox(height: 12),
                  //   SizedBox(
                  //     width: double.infinity,
                  //     child: OutlinedButton(
                  //       onPressed: onProposeTime,
                  //       style: OutlinedButton.styleFrom(
                  //         padding: EdgeInsets.symmetric(vertical: 12),
                  //         side: BorderSide(color: Color(0xFF6CA34D)),
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12)),
                  //       ),
                  //       child: Text('Propose new time'.tr,
                  //           style: TextStyle(
                  //               color: Color(0xFF6CA34D),
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold)),
                  //     ),
                  //   ),
                  // ] else if (proposeTimeAlreadySent) ...[
                  //   SizedBox(height: 12),
                  //   Container(
                  //     width: double.infinity,
                  //     padding: EdgeInsets.symmetric(
                  //         horizontal: 14, vertical: 10),
                  //     decoration: BoxDecoration(
                  //       color: Colors.purple.shade50,
                  //       borderRadius: BorderRadius.circular(10),
                  //       border: Border.all(color: Colors.purple.shade200),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.schedule_outlined,
                  //             size: 16, color: Colors.purple.shade700),
                  //         SizedBox(width: 8),
                  //         Expanded(
                  //           child: Text(
                  //             'Time change proposed — waiting for client response.',
                  //             style: TextStyle(
                  //                 fontSize: 13,
                  //                 color: Colors.purple.shade800,
                  //                 fontWeight: FontWeight.w500),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                ],

                // IN_PROGRESS → cancellation remains available until the job
                // is completed; completion still requires the customer's OTP.
                if (status == 'IN_PROGRESS' && onCompleteWork != null) ...[
                  SizedBox(height: 16),
                  if (onCancel != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel'.tr,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onCompleteWork,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Color(0xFF6CA34D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Complete Work'.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                // COMPLETED → Feedback (API-driven)
                if (status == 'COMPLETED') ...[
                  SizedBox(height: 16),
                  _buildFeedbackButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _customerLabel() {
    final name = job.customerName;
    if (name != null && name.trim().isNotEmpty) return name;
    return 'Customer'.tr;
  }

  Widget _buildFeedbackButton() {
    if (job.isProviderReview) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF6CA34D), size: 18),
            SizedBox(width: 8),
            Text(
              'Feedback submitted'.tr,
              style: TextStyle(
                  color: Color(0xFF6CA34D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Get.to(() => ReviewView(orderId: job.id));
          if (Get.isRegistered<MyJobController>()) {
            Get.find<MyJobController>().loadJobs();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Color(0xFF6CA34D),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          AppStrings.giveAFeedback.tr,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
