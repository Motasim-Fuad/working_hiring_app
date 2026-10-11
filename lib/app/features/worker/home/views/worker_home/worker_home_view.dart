import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';
import 'package:working_hiring/app/core/widgets/home_header.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/data/repositories/user_repository.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/next_jobs_section.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_top_filters.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_calendar_section.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_daily_available_time.dart';

part 'worker_home_view_state.dart';

class WorkerHomeView extends StatefulWidget {
  const WorkerHomeView({super.key});

  @override
  State<WorkerHomeView> createState() => _WorkerHomeViewState();
}
