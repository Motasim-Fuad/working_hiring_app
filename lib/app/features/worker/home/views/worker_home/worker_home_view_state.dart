part of 'worker_home_view.dart';

class _WorkerHomeViewState extends State<WorkerHomeView> {
  late final WorkerHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkerHomeController>();

    _ensureHomeControllerReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          controller.loadInitialData();
        }
      });
    });
  }

  Future<void> _ensureHomeControllerReady() async {
    if (!Get.isRegistered<HomeController>()) {
      final homeController = Get.put(
        HomeController(
          Get.find<CategoryRepository>(),
          Get.find<UserRepository>(),
          Get.find<HelperRepository>(),
          Get.find<OrderRepository>(),
        ),
      );
      if (homeController.userAddresses.isEmpty) {
        await homeController.loadAddresses();
      }
    } else {
      final homeCtrl = Get.find<HomeController>();
      if (homeCtrl.userAddresses.isEmpty) {
        await homeCtrl.loadAddresses();
      }
    }
  }

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
                    maxWidth: AppResponsive.contentMaxWidth,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        WorkerHomeDailyAvailableTime(),
                        SizedBox(height: 20.h),
                        WorkerHomeTopFilters(),
                        SizedBox(height: 20.h),
                        WorkerHomeCalendarSection(),
                        SizedBox(height: 20.h),
                        NextJobsSection(),
                        SizedBox(height: 20.h),
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
