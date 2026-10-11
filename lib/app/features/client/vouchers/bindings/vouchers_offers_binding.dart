import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/vouchers/controllers/vouchers_offers_controller.dart';

class VouchersOffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VouchersOffersController>(() => VouchersOffersController());
  }
}
