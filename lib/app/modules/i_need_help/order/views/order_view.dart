import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/order_model.dart';
import '../controllers/order_controller.dart';
import 'order_detail_view.dart';
import 'review_view.dart';
import '../../payment/views/payment_view.dart';
import '../../../../core/widgets/responsive_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RULE SUMMARY for All Order tab (client side):
//
//  PENDING      → depending on who countered
//  ACCEPT       → Pay  (provider accepted, awaiting payment)
//  CONFIRM      → Cancel  (paid & confirmed — client can still cancel)
//  IN_PROGRESS  → (no button — work is ongoing)
//  COMPLETED    → Give Feedback  (hidden once is_customer_review == true)
//
// "Propose new time" is a PROVIDER action only. Removed from client view.
// ─────────────────────────────────────────────────────────────────────────────

class OrderView extends GetView<OrderController> {
  OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Color(0xFF6CA34D),
            unselectedLabelColor: Color(0xFF999999),
            indicatorColor: Color(0xFF6CA34D),
            indicatorWeight: 3,
            dividerHeight: 0,
            labelStyle:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            tabs: [
              Tab(text: AppStrings.allOrder.tr),
              Tab(text: AppStrings.confirm.tr),
              Tab(text: AppStrings.completed.tr),
            ],
          ),
        ),
        body: ResponsiveCenter(
          maxWidth: AppResponsive.contentMaxWidth,
          padding: EdgeInsets.zero,
          child: TabBarView(
            children: [
            Obx(() => _buildOrderList(
              context: context,
              orders: controller.allOrders.toList(),
              cardBuilder: _buildAllOrderCard,
            )),
            Obx(() => _buildOrderList(
              context: context,
              orders: controller.confirmOrders,
              cardBuilder: _buildConfirmOrderCard,
            )),
            Obx(() => _buildOrderList(
              context: context,
              orders: controller.completedOrders,
              cardBuilder: _buildCompletedOrderCard,
            )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList({
    required BuildContext context,
    required List<OrderModel> orders,
    required Widget Function(BuildContext context, OrderModel order)
    cardBuilder,
  }) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.loadOrders(),
        color: Color(0xFF6CA34D),
        child: ListView(
          children: [
            SizedBox(
              height: AppResponsive.height(400, min: 240, max: 480),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volunteer_activism_outlined,
                        size: AppResponsive.icon(64),
                        color: Color(0xFF6CA34D).withValues(alpha: 0.5)),
                    SizedBox(height: 16.h),
                    Text(AppStrings.beFirstToHelp.tr,
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    SizedBox(height: 8.h),
                    Text(AppStrings.noRequestsRightNow.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.loadOrders(),
      color: Color(0xFF6CA34D),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: orders.length,
        separatorBuilder: (context, index) => Divider(
            height: 32, color: Color(0xFFE5E5E5), thickness: 1),
        itemBuilder: (context, index) => cardBuilder(context, orders[index]),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat("d MMM, yyyy").format(d);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatAmount(num? amount) =>
      '\$${(amount ?? 0).toStringAsFixed(0)}';

  void _navigateToProfile(OrderModel order) {
    if (order.providerName == null) return;
  }

  // ── Countdown shown on CONFIRM cards ──────────────────────────────────────
  Widget _buildCountdownSection(OrderModel order) {
    if (order.status != 'CONFIRM') return SizedBox.shrink();
    if (order.workingDate == null) return SizedBox.shrink();
    try {
      final target = DateTime.parse(order.workingDate!);
      final diff = target.difference(DateTime.now());
      if (diff.isNegative) return SizedBox.shrink();
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Color(0xFFF0F7EB),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                size: 16.sp, color: Color(0xFF6CA34D)),
            SizedBox(width: 8.w),
            Text(
              'Starts In'.trParams({
                'hours': '${diff.inHours}',
                'minutes': '${diff.inMinutes % 60}',
              }),
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6CA34D)),
            ),
          ],
        ),
      );
    } catch (_) {
      return SizedBox.shrink();
    }
  }

  // ── Client counter offer sheet ────────────────────────────────────────────
  void _showClientCounterSheet(BuildContext context, OrderModel order) {
    final priceCtrl = TextEditingController(
        text: (order.amount ?? 0).toStringAsFixed(0));
    final msgCtrl = TextEditingController();
    final budgetObs = (order.amount ?? 0.0).obs;

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
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.r)),
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
                Text('Propose a new budget to the provider.'.tr,
                    style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14.sp)),
                SizedBox(height: 24.h),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(
                      fontSize: 24.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: r'$ ',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Message'.tr,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999))),
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
                      final price =
                          double.tryParse(priceCtrl.text) ?? 0.0;
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
                      Navigator.pop(ctx);
                      controller.sendCounterOffer(
                          order.id, price, msg);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D),
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

  // ── Cancel dialog ─────────────────────────────────────────────────────────
  void _showCancelOrderDialog(BuildContext context, OrderModel order) {
    final TextEditingController reasonController = TextEditingController();
    final isPaid = (order.paymentStatus ?? '').toUpperCase() == 'PAID';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          (isPaid ? "Request Cancellation" : "Cancel Order").tr,
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
              hintText: "Reason for cancellation".tr,
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Back".tr)),
          ElevatedButton(
            onPressed: () {
              controller.cancelOrder(order.id, reasonController.text);
              //Navigator.pop(ctx);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                (isPaid ? "Send Request" : "Confirm Cancel").tr,
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationRequestPanel(OrderModel order) {
    final request = order.pendingCancellationRequest;
    if (request == null) return SizedBox.shrink();
    final requestedByProvider =
        (request.sender ?? '').toUpperCase() == 'PROVIDER';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.h),
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
          if (requestedByProvider)
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.cancelAcceptOrder(
                      order.id, request.id, 'ACCEPT'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D)),
                  child: Text('Accept'.tr,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.cancelAcceptOrder(
                      order.id, request.id, 'DECLINED'),
                  child: Text('Decline'.tr),
                ),
              ),
            ])
          else
            Text('Waiting for provider approval.'.tr),
        ],
      ),
    );
  }

  // ── Report issue sheet ────────────────────────────────────────────────────
  void _showReportIssueSheet(BuildContext context, OrderModel order) {
    String? selectedCategory;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r))),
            child: SingleChildScrollView(
              padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Report an Issue".tr,
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(height: 24.h),
                  Text("Select Issue Category".tr,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: Text("Select a category".tr,
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14.sp)),
                    items: [
                      'Unprofessional Behavior',
                      'Service Not Completed',
                      'Payment Issue',
                      'Safety Concern',
                      'Other'
                    ]
                        .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedCategory = v),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
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
                  SizedBox(height: 20.h),
                  Text("Issue Title".tr,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: "Enter issue title".tr,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
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
                  SizedBox(height: 20.h),
                  Text("Describe the issue".tr,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Describe the issue in detail".tr,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedCategory == null) {
                          Get.snackbar("Error".tr, "Please select an issue category".tr,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                          return;
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0),
                      child: Text("Submit Report".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildReportMenu(BuildContext context, OrderModel order) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey, size: 20.sp),
      onSelected: (value) {
        if (value == 'report') _showReportIssueSheet(context, order);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'report', child: Text("Report Issue".tr)),
      ],
    );
  }

  // ── Shared card header ────────────────────────────────────────────────────
  Widget _buildCardHeader(BuildContext context, OrderModel order,
      {bool showMenu = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(order.title ?? '',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
            SizedBox(width: 8.w),
            _buildStatusBadge(order.status ?? ''),
            if (showMenu) _buildReportMenu(context, order),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            SvgPicture.asset(AppImages.homeAssistance,
                width: 18.sp, height: 18.sp),
            SizedBox(width: 6.w),
            Text(order.categoryName ?? '',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text("Posted by You".tr,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
            SizedBox(width: 4.w),
            Icon(Icons.verified,
                color: Color(0xFF007AFF), size: 16.sp),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            SvgPicture.asset(AppImages.location,
                width: 14.sp,
                height: 14.sp,
                colorFilter: ColorFilter.mode(
                    Color(0xFFFF3B30), BlendMode.srcIn)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                  order.address == 'San Francisco CA'
                      ? AppStrings.sanFranciscoCA.tr
                      : (order.address ?? ''),
                  style:
                  TextStyle(fontSize: 14.sp, color: Colors.black87)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared schedule + provider row ────────────────────────────────────────
  // ── Time-change request banner (provider proposed a new time) ─────────────
  Widget _buildTimeChangeBanner(OrderModel order) {
    return Obx(() {
      final req = controller.pendingTimeChangeFor(order.id);
      if (req == null) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_outlined,
                    size: 18.sp, color: Colors.purple.shade700),
                SizedBox(width: 8.w),
                Text('Provider proposed a new time'.tr,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900)),
              ],
            ),
            SizedBox(height: 8.h),
            if ((req.proposedDate ?? '').isNotEmpty)
              Text('${'Date'.tr}: ${req.proposedDate}',
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.purple.shade800)),
            if ((req.proposedTime ?? '').isNotEmpty)
              Text('${'Time'.tr}: ${req.proposedTime}',
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.purple.shade800)),
            if ((req.message ?? '').isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text('${'Reason'.tr}: ${req.message}',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.purple.shade700,
                      fontStyle: FontStyle.italic)),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.respondToTimeChange(order.id, 'ACCEPT'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6CA34D),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        elevation: 0),
                    child: Text('Accept'.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.respondToTimeChange(order.id, 'DECLINED'),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        side: BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r))),
                    child: Text('Decline'.tr,
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScheduleRow(BuildContext context, OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Get.to(() => OrderDetailView(order: order)),
                child: Row(
                  children: [
                    SvgPicture.asset(AppImages.calendar,
                        width: 14.sp,
                        height: 14.sp,
                        colorFilter: ColorFilter.mode(
                            Color(0xFF6CA34D), BlendMode.srcIn)),
                    SizedBox(width: 4.w),
                    Text(_formatDate(order.workingDate),
                        style: TextStyle(
                            fontSize: 13.sp, color: Colors.black87)),
                    SizedBox(width: 12.w),
                    SvgPicture.asset(AppImages.time,
                        width: 14.sp,
                        height: 14.sp,
                        colorFilter: ColorFilter.mode(
                            Color(0xFF6CA34D), BlendMode.srcIn)),
                    SizedBox(width: 4.w),
                    Text(order.workingStartTime ?? '',
                        style: TextStyle(
                            fontSize: 13.sp, color: Colors.black87)),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _navigateToProfile(order),
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 20.sp, color: Colors.grey.shade400),
                    SizedBox(width: 8.w),
                    Text(
                      order.providerName?.isNotEmpty == true
                          ? order.providerName!
                          : 'Pending Worker',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.to(() => OrderDetailView(order: order)),
          child: Text(_formatAmount(order.amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black)),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1 — ALL ORDERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAllOrderCard(BuildContext context, OrderModel order) {
    final status = order.effectiveStatus;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailView(order: order)),
            child: _buildCardHeader(context, order, showMenu: true),
          ),
          SizedBox(height: 12.h),
          _buildScheduleRow(context, order),

          // ── Action buttons (client side) ──────────────────────────────
          // PENDING → negotiation logic (using a helper method)
          if (status == 'PENDING') ...[
            SizedBox(height: 16.h),
            _buildPendingActions(context, order),
          ]
          // ACCEPT → Pay (awaiting payment)
          else if (status == 'ACCEPT') ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Get.to(() => PaymentView(), arguments: order),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: Color(0xFF6CA34D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0),
                child: Text(AppStrings.pay.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelOrderDialog(context, order),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('Cancel'.tr,
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ]
          // CONFIRM → Cancel + provider's time-change request if any
          else if (status == 'CONFIRM' ||
              status == 'CANCELLATION_REQUEST') ...[
              _buildTimeChangeBanner(order),
              _buildCancellationRequestPanel(order),
              SizedBox(height: 16.h),
              if (order.pendingCancellationRequest == null)
                SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      _showCancelOrderDialog(context, order),
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                  child: Text("Cancel".tr,
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]
            else if (status == 'IN_PROGRESS') ...[
              _buildCancellationRequestPanel(order),
              if (order.pendingCancellationRequest == null) ...[
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelOrderDialog(context, order),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Cancel'.tr,
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ]
            // COMPLETED → Feedback (API-driven)
            else if (status == 'COMPLETED') ...[
                SizedBox(height: 16.h),
                _feedbackButton(order),
              ],
          // IN_PROGRESS → no button (work is ongoing, provider is active)
        ],
      ),
    );
  }

  // ── Helper method for PENDING actions ────────────────────────────────────
  Widget _buildPendingActions(BuildContext context, OrderModel order) {
    final bool providerCountered = controller.hasProviderCountered(order.id);
    final bool clientCountered = controller.hasClientCountered(order.id);

    if (!providerCountered) {
      // ── ক্লায়েন্ট অফার পাঠিয়েছে, প্রোভাইডার এখনো কাউন্টার দেয়নি → শুধু Cancel
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showCancelOrderDialog(context, order),
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r))),
          child: Text('Cancel'.tr,
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ),
      );
    } else if (providerCountered && !clientCountered) {
      // ── প্রোভাইডার কাউন্টার দিয়েছে, ক্লায়েন্ট এখনো কাউন্টার দেয়নি → Accept, Counter, Cancel
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.acceptOrder(order.id),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: Color(0xFF6CA34D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0),
              child: Text('Accept'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showCancelOrderDialog(context, order),
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                  child: Text('Cancel'.tr,
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              if (!clientCountered) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showClientCounterSheet(context, order),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                            color: Color(0xFF6CA34D)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r))),
                    child: Text('Counter'.tr,
                        style: TextStyle(
                            color: Color(0xFF6CA34D),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    } else {
      // Client used their one counter. Their own proposal cannot be accepted
      // or countered again; only Decline remains until provider responds.
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showCancelOrderDialog(context, order),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            side: BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text('Decline'.tr,
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2 — CONFIRM ORDERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildConfirmOrderCard(BuildContext context, OrderModel order) {
    final status = order.effectiveStatus;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailView(order: order)),
            child: _buildCardHeader(context, order),
          ),
          SizedBox(height: 12.h),
          _buildScheduleRow(context, order),
          _buildCountdownSection(order),
          SizedBox(height: 16.h),

          // ACCEPT → Pay
          if (status == 'ACCEPT') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Get.to(() => PaymentView(), arguments: order),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: Color(0xFF6CA34D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0),
                child: Text(AppStrings.pay.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelOrderDialog(context, order),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('Cancel'.tr,
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ]
          // CONFIRM → Cancel + provider's time-change request if any
          else if (status == 'CONFIRM' ||
              status == 'CANCELLATION_REQUEST') ...[
            _buildTimeChangeBanner(order),
            _buildCancellationRequestPanel(order),
            SizedBox(height: 16.h),
            if (order.pendingCancellationRequest == null)
              SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _showCancelOrderDialog(context, order),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r))),
                child: Text("Cancel".tr,
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]
          else if (status == 'IN_PROGRESS') ...[
            _buildCancellationRequestPanel(order),
            if (order.pendingCancellationRequest == null) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCancelOrderDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Cancel'.tr,
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ]
          else
            SizedBox.shrink(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3 — COMPLETED ORDERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCompletedOrderCard(BuildContext context, OrderModel order) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailView(order: order)),
            child: _buildCardHeader(context, order, showMenu: true),
          ),
          SizedBox(height: 12.h),
          _buildScheduleRow(context, order),
          SizedBox(height: 16.h),
          _feedbackButton(order),
        ],
      ),
    );
  }

  // ── Feedback button — API-driven ─────────────────────────────────────────
  Widget _feedbackButton(OrderModel order) {
    if (order.isCustomerReview) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle,
                color: Color(0xFF6CA34D), size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              "Feedback submitted".tr,
              style: TextStyle(
                  color: Color(0xFF6CA34D),
                  fontSize: 15.sp,
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
          await Get.to(() => ReviewView(orderId: order.id));
          controller.loadOrders();
        },
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            backgroundColor: Color(0xFF6CA34D),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 0),
        child: Text(AppStrings.giveAFeedback.tr,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'PENDING':
        bg = Color(0xFFE5F0FF);
        text = Color(0xFF007AFF);
        label = AppStrings.created.tr;
      case 'IN_PROGRESS':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = AppStrings.progress.tr;
      case 'COMPLETED':
        bg = Color(0xFFE8FCEC);
        text = Color(0xFF28A745);
        label = AppStrings.completed.tr;
      case 'CONFIRM':
        bg = Color(0xFFE8FCEC);
        text = Color(0xFF28A745);
        label = "Confirmed";
      case 'CANCELLATION_REQUEST':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = "Cancellation Pending";
      case 'ACCEPT':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = "Accepted";
      case 'CANCELLED':
        bg = Color(0xFFFFE5E5);
        text = Color(0xFFFF3B30);
        label = "Cancelled";
      default:
        bg = Color(0xFFE5F0FF);
        text = Color(0xFF007AFF);
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(100.r)),
      child: Text(label,
          style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp)),
    );
  }
}
