import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../i_need_help/dashboard/views/dashboard_view.dart';
import '../../i_want_to_work/dashboard/views/worker_dashboard_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<MainController>(
          id: 'main-phase',
          builder: (mainController) => Obx(() {
            if (!mainController.isReady.value) {
              return const SizedBox.shrink();
            }
            final phase = mainController.activePhase.value;
            return KeyedSubtree(
              key: ValueKey<int>(phase),
              child: phase == 2
                  ? WorkerDashboardView()
                  : DashboardView(),
            );
          }),
        ),
      ),
    );
  }
}
