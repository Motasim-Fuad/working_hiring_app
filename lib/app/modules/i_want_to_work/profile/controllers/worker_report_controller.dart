import 'package:get/get.dart';

class ReportModel {
  final String id;
  final String title;
  final String date;
  final String amount;
  final String status;

  ReportModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class WorkerReportController extends GetxController {
  // Dashboard Amounts
  final RxString totalPayoutsAmount = '\$0.00'.obs;
  final RxString upcomingAmount = '\$0.00'.obs;
  final RxString paidAmount = '\$0.00'.obs;
  final RxString availableAmount = '\$0.00'.obs;

  // Reports
  final RxList<ReportModel> latestReports = <ReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock amounts
    totalPayoutsAmount.value = '\$1,435.50';
    upcomingAmount.value = '\$150.00';
    paidAmount.value = '\$1,240.50';
    availableAmount.value = '\$45.00';

    // Mock reports
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
