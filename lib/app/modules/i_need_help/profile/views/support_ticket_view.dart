// lib/modules/client/profile/support_ticket/views/support_ticket_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/service/api_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../controllers/support_ticket_controller.dart';

class SupportTicketView extends StatelessWidget {
  SupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketRepository>()) {
      Get.put(TicketRepository(Get.find<ApiClient>()));
    }
    final controller = Get.put(SupportTicketController(Get.find<TicketRepository>()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.supportTicket.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              _buildLabel(AppStrings.subject.tr),
              SizedBox(height: 8.h),
              _buildTextField(controller.subjectController, hint: AppStrings.subject.tr),
              SizedBox(height: 24.h),

              // Order
              _buildLabel(AppStrings.orderLabel.tr, withInfo: true),
              SizedBox(height: 8.h),
              _buildOrderSelector(context, controller),
              SizedBox(height: 24.h),

              // Attachment
              _buildLabel(AppStrings.attachment.tr, withInfo: true),
              SizedBox(height: 8.h),
              _buildAttachmentTile(controller),
              SizedBox(height: 24.h),

              // Message
              _buildLabel(AppStrings.yourMessage.tr),
              SizedBox(height: 8.h),
              _buildMessageField(controller.summaryController),
              SizedBox(height: 32.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.submitTicket.tr,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text, {bool withInfo = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (withInfo) ...[
          SizedBox(width: 6.w),
          Icon(Icons.info, color: Color(0xFFBDBDBD), size: 16.sp),
        ],
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildMessageField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: 8,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildOrderSelector(BuildContext context, SupportTicketController controller) {
    return InkWell(
      onTap: () => _showOrderSelectionSheet(context, controller),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final order = controller.selectedOrder.value;
              return Text(
                order != null
                    ? (order.title ?? 'Order #${order.id}')
                    : AppStrings.selectYourOrder.tr,
                style: TextStyle(
                  color: order != null ? Colors.black : Color(0xFF9E9E9E),
                  fontSize: 14.sp,
                ),
              );
            }),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E), size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showOrderSelectionSheet(BuildContext context, SupportTicketController controller) {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          child: Obx(() {
            if (controller.orders.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No orders found.'.tr)),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: controller.orders.map((order) {
                return ListTile(
                  title: Text(order.title ?? 'Order #${order.id}'),
                  onTap: () => controller.selectOrder(order),
                );
              }).toList(),
            );
          }),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAttachmentTile(SupportTicketController controller) {
    return InkWell(
      onTap: controller.showAttachmentOptions,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Obx(() {
              final isAttached = controller.attachedFileName.value.isNotEmpty;
              return Expanded(
                child: Text(
                  isAttached ? controller.attachedFileName.value : AppStrings.addAttachment.tr,
                  style: TextStyle(
                    color: isAttached ? Colors.black : Color(0xFF9E9E9E),
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }),
            SizedBox(width: 8.w),
            Obx(() {
              final isAttached = controller.attachedFileName.value.isNotEmpty;
              return Icon(
                isAttached ? Icons.check_circle : Icons.attach_file,
                color: isAttached ? Color(0xFF32C759) : Color(0xFF9E9E9E),
                size: 20.sp,
              );
            }),
          ],
        ),
      ),
    );
  }

}
