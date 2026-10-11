import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/profile_page_skeleton.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/ticket_list_shimmer.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/shimmer/helper_list_shimmer.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/shimmer/recommended_helpers_shimmer.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/shimmer/order_list_shimmer.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/shimmer/order_detail_shimmer.dart';
import 'package:working_hiring/app/features/client/saved_helpers/views/saved_helpers/widgets/shimmer/saved_helpers_shimmer.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/shimmer/ticket_conversation_shimmer.dart';
import 'package:working_hiring/app/features/notification/views/notification/widgets/shimmer/notification_list_shimmer.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/shimmer/job_list_shimmer.dart';

Future<void> _pump(WidgetTester tester, Widget Function() build) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        home: Scaffold(body: Builder(builder: (_) => build())),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
}

void main() {
  final skeletons = <String, Widget Function()>{
    'order list': () => const OrderListShimmer(),
    'order detail': () => const OrderDetailShimmer(),
    'helper list': () => const HelperListShimmer(),
    'saved helpers': () => const SavedHelpersShimmer(),
    'recommended helpers': () =>
        const SingleChildScrollView(child: RecommendedHelpersShimmer()),
    'ticket list': () => const TicketListShimmer(),
    'ticket conversation': () => const TicketConversationShimmer(),
    'notifications': () => const NotificationListShimmer(),
    'job list': () => const JobListShimmer(),
    'profile': () => ProfilePageSkeleton(
      avatarSize: 100.r,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
    ),
  };

  for (final entry in skeletons.entries) {
    testWidgets('${entry.key} skeleton lays out without overflow', (
      tester,
    ) async {
      await _pump(tester, entry.value);
    });
  }
}
