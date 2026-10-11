import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/payment/controllers/billing_payments_controller.dart';

class BillingPaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillingPaymentsController>(
      () => BillingPaymentsController(),
      fenix: true,
    );
  }
}
