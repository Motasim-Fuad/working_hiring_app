import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/service/reviewed_orders.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';

part 'review_view_state.dart';

class ReviewView extends StatefulWidget {
  final int orderId;
  const ReviewView({super.key, required this.orderId});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}
