import 'package:get/get.dart';
import '../controllers/vouchers_offers_controller.dart';

class VouchersOffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VouchersOffersController>(
      () => VouchersOffersController(),
    );
  }
}
