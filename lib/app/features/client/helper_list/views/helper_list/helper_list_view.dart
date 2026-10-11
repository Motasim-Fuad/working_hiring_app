import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/features/chat/views/chat/chat_view.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/helper_list_filter_section.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/helper_list_sort_section.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/helper_list_helper_card.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/shimmer/helper_list_shimmer.dart';

part 'helper_list_view_state.dart';

class HelperListView extends StatefulWidget {
  const HelperListView({super.key});

  @override
  State<HelperListView> createState() => _HelperListViewState();
}
