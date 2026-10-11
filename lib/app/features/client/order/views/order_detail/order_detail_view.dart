import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_info_tile.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_otp_section.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_attachments_section.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_changes_requests_section.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_status_timeline.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_helpers.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/shimmer/order_detail_shimmer.dart';

part 'order_detail_view_state.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;
  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}
