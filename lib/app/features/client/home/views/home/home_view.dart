import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/widgets/home_header.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/home_banner.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/home_my_activity_section.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/home_search_bar.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/recommended_helpers_section.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/recent_activity_section.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/home_service_grid.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: RefreshIndicator(
                color: Color(0xFF6CA34D),
                onRefresh: () => controller.loadInitialData(),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ResponsiveCenter(
                    maxWidth: AppResponsive.wideContentMaxWidth,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeBanner(),
                        HomeSearchBar(),
                        HomeMyActivitySection(),
                        HomeServiceGrid(),
                        RecommendedHelpersSection(),
                        RecentActivitySection(),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
