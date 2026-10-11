part of 'order_detail_view.dart';

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

  Future<void> _refreshOrder() async {
    await controller.loadOrderDetail(widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isDetailLoading.value) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: const OrderDetailShimmer(),
        );
      }

      final order = controller.selectedOrder.value ?? widget.order;
      final status = order.status ?? '';
      final createdAt = parseDateTime(order.createdAt);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: _refreshOrder,
          color: Color(0xFF6CA34D),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                Text(
                  'Placed On Date'.trParams({'date': formatDate(createdAt)}),
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 20.h),

                if (order.title != null && order.title!.isNotEmpty) ...[
                  OrderDetailInfoTile(label: 'Title', value: order.title!),
                  SizedBox(height: 12.h),
                ],
                if (order.description != null &&
                    order.description!.isNotEmpty) ...[
                  OrderDetailInfoTile(
                    label: 'Description',
                    value: order.description!,
                  ),
                  SizedBox(height: 12.h),
                ],

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
                      formatCurrency(order.amount ?? order.budget ?? 0),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6CA34D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                if (order.workingDate != null ||
                    order.workingStartTime != null) ...[
                  OrderDetailInfoTile(
                    label: 'Working Schedule',
                    value: formatWorkingSchedule(
                      order.workingDate,
                      order.workingStartTime,
                      order.endTime,
                      order.workingHour,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                if (order.address != null && order.address!.isNotEmpty) ...[
                  OrderDetailInfoTile(label: 'Address', value: order.address!),
                  SizedBox(height: 12.h),
                ],

                if (order.providerName != null &&
                    order.providerName!.isNotEmpty) ...[
                  OrderDetailInfoTile(
                    label: 'Provider',
                    value: order.providerName!,
                  ),
                  SizedBox(height: 12.h),
                ],
                if (order.customerName != null &&
                    order.customerName!.isNotEmpty) ...[
                  OrderDetailInfoTile(
                    label: 'Customer',
                    value: order.customerName!,
                  ),
                  SizedBox(height: 12.h),
                ],

                if (order.categoryName != null &&
                    order.categoryName!.isNotEmpty) ...[
                  OrderDetailInfoTile(
                    label: 'Category',
                    value: order.categoryName!,
                  ),
                  SizedBox(height: 12.h),
                ],
                if (order.subCategoryName != null &&
                    order.subCategoryName!.isNotEmpty) ...[
                  OrderDetailInfoTile(
                    label: 'Sub-category',
                    value: order.subCategoryName!,
                  ),
                  SizedBox(height: 12.h),
                ],

                if (order.confirmationOtp != null &&
                    order.confirmationOtp!.isNotEmpty) ...[
                  OrderDetailOtpSection(otp: order.confirmationOtp!),
                  SizedBox(height: 16.h),
                ],

                if (order.attachments != null &&
                    order.attachments!.isNotEmpty) ...[
                  OrderDetailAttachmentsSection(
                    attachments: order.attachments!,
                  ),
                  SizedBox(height: 16.h),
                ],

                if (order.changesRequests != null &&
                    order.changesRequests!.isNotEmpty) ...[
                  OrderDetailChangesRequestsSection(
                    requests: order.changesRequests!,
                  ),
                ],

                if (order.acceptedAt != null ||
                    order.startedAt != null ||
                    order.completedAt != null) ...[
                  SizedBox(height: 16.h),
                  OrderDetailStatusTimeline(order: order),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

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
}
