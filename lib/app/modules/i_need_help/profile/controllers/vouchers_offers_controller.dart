import 'package:get/get.dart';
import '../../../../data/models/voucher_model.dart';

class VouchersOffersController extends GetxController {
  final RxList<VoucherModel> allVouchers = <VoucherModel>[].obs;
  final RxDouble totalSaved = 0.0.obs;
  final RxString selectedFilter = 'Sort'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyVouchers();
  }

  void _loadDummyVouchers() {
    allVouchers.assignAll([
      VoucherModel(
        id: '1',
        code: 'DEALNAO',
        discountAmount: 150,
        merchantName: 'DEALNAO',
        minSpend: 450,
        expiryDate: DateTime(2026, 3, 31),
        type: 'Restaurants',
      ),
      VoucherModel(
        id: '2',
        code: 'PROMO150',
        discountAmount: 150,
        merchantName: 'dmart',
        minSpend: 500,
        expiryDate: DateTime(2026, 3, 31),
        type: 'Shops',
      ),
      VoucherModel(
        id: '3',
        code: 'EATNOW',
        discountAmount: 100,
        merchantName: 'FoodPanda',
        minSpend: 300,
        expiryDate: DateTime(2026, 4, 15),
        type: 'Restaurants',
      ),
    ]);
  }

  void addVoucher(String code) {
    if (code.isNotEmpty) {
      // Logic to add a new voucher (placeholder logic)
      final newVoucher = VoucherModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: code.toUpperCase(),
        discountAmount: 150,
        merchantName: code.toUpperCase(),
        minSpend: 500,
        expiryDate: DateTime.now().add(Duration(days: 30)),
        type: 'Shops',
      );
      allVouchers.insert(0, newVoucher);
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    // Filtering logic can be added here if needed
  }
}
