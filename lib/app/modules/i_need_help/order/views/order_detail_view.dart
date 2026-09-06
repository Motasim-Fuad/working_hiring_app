import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/modules/i_need_help/order/controllers/order_controller.dart';
import '../../../../../app/data/models/order_model.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;
  OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final OrderController controller = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadOrderDetail(widget.order.id);
    });
  }

  @override
  void dispose() {
    controller.selectedOrder.value = null;
    super.dispose();
  }

  // --- Refresh method ---
  Future<void> _refreshOrder() async {
    await controller.loadOrderDetail(widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isDetailLoading.value) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF6CA34D)),
          ),
        );
      }

      final order = controller.selectedOrder.value ?? widget.order;
      final status = order.status ?? '';
      final createdAt = _parseDateTime(order.createdAt);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(), // now includes refresh button
        body: RefreshIndicator(
          onRefresh: _refreshOrder,
          color: Color(0xFF6CA34D),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- Header: Order ID & Status -----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // ----- Created At -----
                Text(
                  'Placed On Date'.trParams({
                    'date': _formatDate(createdAt),
                  }),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20.h),

                // ----- Title & Description -----
                if (order.title != null && order.title!.isNotEmpty) ...[
                  _buildInfoTile('Title', order.title!),
                  SizedBox(height: 12.h),
                ],
                if (order.description != null && order.description!.isNotEmpty) ...[
                  _buildInfoTile('Description', order.description!),
                  SizedBox(height: 12.h),
                ],

                // ----- Amount / Budget -----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatCurrency(order.amount ?? order.budget ?? 0),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6CA34D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ----- Working Details -----
                if (order.workingDate != null || order.workingStartTime != null) ...[
                  _buildInfoTile(
                    'Working Schedule',
                    _formatWorkingSchedule(
                      order.workingDate,
                      order.workingStartTime,
                      order.endTime,
                      order.workingHour,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // ----- Address -----
                if (order.address != null && order.address!.isNotEmpty) ...[
                  _buildInfoTile('Address', order.address!),
                  SizedBox(height: 12.h),
                ],

                // ----- Provider & Customer -----
                if (order.providerName != null && order.providerName!.isNotEmpty) ...[
                  _buildInfoTile('Provider', order.providerName!),
                  SizedBox(height: 12.h),
                ],
                if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                  _buildInfoTile('Customer', order.customerName!),
                  SizedBox(height: 12.h),
                ],

                // ----- Category -----
                if (order.categoryName != null && order.categoryName!.isNotEmpty) ...[
                  _buildInfoTile('Category', order.categoryName!),
                  SizedBox(height: 12.h),
                ],
                if (order.subCategoryName != null && order.subCategoryName!.isNotEmpty) ...[
                  _buildInfoTile('Sub-category', order.subCategoryName!),
                  SizedBox(height: 12.h),
                ],

                // ----- Confirmation OTP -----
                if (order.confirmationOtp != null && order.confirmationOtp!.isNotEmpty) ...[
                  _buildOtpSection(order.confirmationOtp!),
                  SizedBox(height: 16.h),
                ],

                // ----- Attachments -----
                if (order.attachments != null && order.attachments!.isNotEmpty) ...[
                  _buildAttachmentsSection(order.attachments!),
                  SizedBox(height: 16.h),
                ],

                // ----- Changes Requests -----
                if (order.changesRequests != null && order.changesRequests!.isNotEmpty) ...[
                  _buildChangesRequestsSection(order.changesRequests!),
                ],

                // ----- Status Timeline -----
                if (order.acceptedAt != null || order.startedAt != null || order.completedAt != null) ...[
                  SizedBox(height: 16.h),
                  _buildStatusTimeline(order),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  // ===== Helper Widgets =====

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Order Detail'.tr,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.black),
          onPressed: _refreshOrder,
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection(String otp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmation OTP'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Text(
            otp,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
              letterSpacing: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(List<String> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  attachments[index],
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100.w,
                    height: 100.h,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChangesRequestsSection(List<ChangesRequestModel> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Requests'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...requests.map((req) {
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (req.requestType != null)
                    Text(
                      'Type Value'.trParams({
                        'type': '${req.requestType}',
                      }),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  if (req.status != null)
                    Text(
                      'Status Value'.trParams({
                        'status': req.status!.tr,
                      }),
                      style: TextStyle(fontSize: 13.sp, color: _getStatusColor(req.status!)),
                    ),
                  if (req.message != null)
                    Text(
                      'Message Value'.trParams({
                        'message': '${req.message}',
                      }),
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  if (req.proposedDate != null)
                    Text(
                      'Proposed Date Value'.trParams({
                        'date': '${req.proposedDate}',
                      }),
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  if (req.proposedTime != null)
                    Text(
                      'Proposed Time Value'.trParams({
                        'time': '${req.proposedTime}',
                      }),
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  if (req.proposedAmount != null)
                    Text(
                      'Proposed Amount Value'.trParams({
                        'amount': _formatCurrency(req.proposedAmount!),
                      }),
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusTimeline(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        if (order.acceptedAt != null)
          _timelineItem('Accepted', order.acceptedAt!),
        if (order.startedAt != null)
          _timelineItem('Started', order.startedAt!),
        if (order.completedAt != null)
          _timelineItem('Completed', order.completedAt!),
      ],
    );
  }

  Widget _timelineItem(String label, String date) {
    final dt = _parseDateTime(date);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10.w, color: Color(0xFF6CA34D)),
          SizedBox(width: 8.w),
          Text(
            'Label Date Value'.trParams({
              'label': label.tr,
              'date': _formatDate(dt),
            }),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ===== Utility Functions =====

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  String _formatWorkingSchedule(String? date, String? start, String? end, int? hours) {
    final parts = <String>[];
    if (date != null) {
      parts.add('Date Value'.trParams({'date': date}));
    }
    if (start != null) {
      parts.add('Start Value'.trParams({'time': start}));
    }
    if (end != null) {
      parts.add('End Value'.trParams({'time': end}));
    }
    if (hours != null) {
      parts.add('Duration Hours'.trParams({'hours': '$hours'}));
    }
    return parts.join('\n');
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
      case 'ACCEPT':
      case 'CONFIRM':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }
}
