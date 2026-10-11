import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/report/models/report_model.dart';
export 'package:working_hiring/app/features/worker/report/models/report_model.dart';

class WorkerReportController extends GetxController {
  final RxString totalPayoutsAmount = '\$0.00'.obs;
  final RxString upcomingAmount = '\$0.00'.obs;
  final RxString paidAmount = '\$0.00'.obs;
  final RxString availableAmount = '\$0.00'.obs;

  final RxList<ReportModel> latestReports = <ReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    totalPayoutsAmount.value = '\$1,435.50';
    upcomingAmount.value = '\$150.00';
    paidAmount.value = '\$1,240.50';
    availableAmount.value = '\$45.00';

    latestReports.assignAll([
      ReportModel(
        id: '1',
        title: 'Weekly Payout'.tr,
        date: 'Oct 15, 2026',
        amount: '\$150.00',
        status: 'Available',
      ),
      ReportModel(
        id: '2',
        title: 'Bonus Payout'.tr,
        date: 'Oct 10, 2026',
        amount: '\$50.00',
        status: 'Paid',
      ),
      ReportModel(
        id: '3',
        title: 'Weekly Payout'.tr,
        date: 'Oct 03, 2026',
        amount: '\$145.50',
        status: 'Paid',
      ),
    ]);
  }
}
