import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_list.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/cards/all_order_card.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/cards/confirm_order_card.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/cards/completed_order_card.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

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
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
              Obx(
                () => OrderList(
                  orders: controller.allOrders.toList(),
                  cardBuilder: (context, order) => AllOrderCard(order: order),
                ),
              ),
              Obx(
                () => OrderList(
                  orders: controller.confirmOrders,
                  cardBuilder: (context, order) =>
                      ConfirmOrderCard(order: order),
                ),
              ),
              Obx(
                () => OrderList(
                  orders: controller.completedOrders,
                  cardBuilder: (context, order) =>
                      CompletedOrderCard(order: order),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
