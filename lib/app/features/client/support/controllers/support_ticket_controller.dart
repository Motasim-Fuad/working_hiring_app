import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/data/models/ticket_model.dart';
import 'package:working_hiring/app/data/repositories/ticket_repository.dart';

class SupportTicketController extends GetxController {
  final TicketRepository _ticketRepo;

  SupportTicketController(this._ticketRepo);

  final RxBool isLoading = false.obs;
  final RxList<TicketModel> ticketHistory = <TicketModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final RxString attachedFileName = ''.obs;
  final RxString attachedFilePath = ''.obs;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadTickets();
    loadOrders();
  }

  @override
  void onClose() {
    subjectController.dispose();
    summaryController.dispose();
    super.onClose();
  }

  String getOrderTitle(int? orderId) {
    if (orderId == null) return '';
    final order = orders.firstWhereOrNull((o) => o.id == orderId);
    return order?.title ?? 'Order #$orderId';
  }

  Future<void> loadOrders() async {
    try {
      final orderList = await _ticketRepo.getCustomerOrders(
        profileType: 'CUSTOMER',
      );
      orders.assignAll(orderList);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('loadOrders error: $e');
    }
  }

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
    Get.back();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    try {
      final tickets = await _ticketRepo.getTickets(profileType: 'CUSTOMER');
      ticketHistory.assignAll(tickets);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('loadTickets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        attachedFileName.value = image.name;
        attachedFilePath.value = image.path;
        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        attachedFileName.value = result.files.single.name;
        attachedFilePath.value = result.files.single.path ?? '';
        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.black87),
              title: Text(AppStrings.camera.tr),
              onTap: () => pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.black87),
              title: Text(AppStrings.photoGallery.tr),
              onTap: () => pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.black87),
              title: Text(AppStrings.document.tr),
              onTap: () => pickDocument(),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  Future<void> submitTicket() async {
    final subject = subjectController.text.trim();
    final summary = summaryController.text.trim();
    final order = selectedOrder.value;

    if (subject.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please enter a subject.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (summary.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please describe your issue.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (order == null) {
      Get.snackbar(
        'Error'.tr,
        'Please select an order.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _ticketRepo.createTicket(
        subject: subject,
        summary: summary,
        orderId: order.id,
        attachmentPath: attachedFilePath.value.isNotEmpty
            ? attachedFilePath.value
            : null,
        profileType: 'CUSTOMER',
      );
      subjectController.clear();
      summaryController.clear();
      attachedFileName.value = '';
      attachedFilePath.value = '';
      selectedOrder.value = null;
      Get.back();
      await loadTickets();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('submitTicket error: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to submit ticket.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
