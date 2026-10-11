import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/animations/fade_slide_in.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/state/empty_state_view.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/shimmer/order_list_shimmer.dart';

class OrderList extends GetView<OrderController> {
  final List<OrderModel> orders;
  final Widget Function(BuildContext context, OrderModel order) cardBuilder;

  const OrderList({super.key, required this.orders, required this.cardBuilder});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadOrders,
      color: AppColors.primary,
      child: Obx(() {
        final loading = controller.isLoading.value;
        if (orders.isEmpty && loading) {
          return const OrderListShimmer();
        }
        if (orders.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyStateView(
                    icon: Icons.volunteer_activism_outlined,
                    title: AppStrings.beFirstToHelp.tr,
                    message: AppStrings.noRequestsRightNow.tr,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: orders.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 32, color: Color(0xFFE5E5E5), thickness: 1),
          itemBuilder: (context, index) => FadeSlideIn(
            index: index,
            child: cardBuilder(context, orders[index]),
          ),
        );
      }),
    );
  }
}
