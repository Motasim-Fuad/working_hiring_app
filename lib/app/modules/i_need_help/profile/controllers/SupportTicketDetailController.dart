// lib/modules/client/profile/support_ticket/controllers/support_ticket_detail_controller.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:working_hiring/app/service/api_service.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/repositories/ticket_repository.dart';


class SupportTicketDetailController extends GetxController {
  final TicketRepository _ticketRepo;
  final int ticketId;
  final String profileType; // 'CUSTOMER' or 'PROVIDER'

  SupportTicketDetailController(this._ticketRepo, this.ticketId, this.profileType);

  final Rx<TicketModel?> ticket = Rx<TicketModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isReplying = false.obs;

  final TextEditingController replyController = TextEditingController();
  final RxString replyAttachmentPath = ''.obs;
  final RxString replyAttachmentName = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadTicketDetail();
  }

  @override
  void onClose() {
    replyController.dispose();
    super.onClose();
  }

  Future<void> loadTicketDetail() async {
    isLoading.value = true;
    try {
      final t = await _ticketRepo.getTicketDetail(ticketId, profileType: profileType);
      ticket.value = t;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('loadTicketDetail error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReply() async {
    final message = replyController.text.trim();
    if (message.isEmpty) {
      Get.snackbar('Error'.tr, 'Please enter a message.'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isReplying.value = true;
    try {
      final reply = await _ticketRepo.replyToTicket(
        ticketId,
        message,
        attachmentPath: replyAttachmentPath.value.isNotEmpty ? replyAttachmentPath.value : null,
        profileType: profileType,
      );
      // Update local ticket
      final currentTicket = ticket.value;
      if (currentTicket != null) {
        final updated = TicketModel(
          id: currentTicket.id,
          user: currentTicket.user,
          userName: currentTicket.userName,
          userProfileType: currentTicket.userProfileType,
          subject: currentTicket.subject,
          order: currentTicket.order,
          status: currentTicket.status,
          summary: currentTicket.summary,
          attachment: currentTicket.attachment,
          lastMessage: reply.message,
          lastReplyAt: reply.createdAt,
          createdAt: currentTicket.createdAt,
          updatedAt: currentTicket.updatedAt,
          replies: [...currentTicket.replies, reply],
        );
        ticket.value = updated;
      }
      replyController.clear();
      replyAttachmentPath.value = '';
      replyAttachmentName.value = '';
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('sendReply error: $e');
      Get.snackbar('Error'.tr, 'Failed to send reply.'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isReplying.value = false;
    }
  }

  Future<void> closeTicket() async {
    try {
      await _ticketRepo.closeTicket(ticketId, profileType: profileType);
      final currentTicket = ticket.value;
      if (currentTicket != null) {
        final updated = TicketModel(
          id: currentTicket.id,
          user: currentTicket.user,
          userName: currentTicket.userName,
          userProfileType: currentTicket.userProfileType,
          subject: currentTicket.subject,
          order: currentTicket.order,
          status: 'closed',
          summary: currentTicket.summary,
          attachment: currentTicket.attachment,
          lastMessage: currentTicket.lastMessage,
          lastReplyAt: currentTicket.lastReplyAt,
          createdAt: currentTicket.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
          replies: currentTicket.replies,
        );
        ticket.value = updated;
      }
      Get.back(result: true);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('closeTicket error: $e');
      Get.snackbar('Error'.tr, 'Failed to close ticket.'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Attachment pickers
  Future<void> pickReplyImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        replyAttachmentName.value = image.name;
        replyAttachmentPath.value = image.path;
        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> pickReplyDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        replyAttachmentName.value = result.files.single.name;
        replyAttachmentPath.value = result.files.single.path ?? '';
        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  void showReplyAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.black87),
              title: Text('Camera'.tr),
              onTap: () => pickReplyImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.black87),
              title: Text('Gallery'.tr),
              onTap: () => pickReplyImage(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.black87),
              title: Text('Document'.tr),
              onTap: () => pickReplyDocument(),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void removeReplyAttachment() {
    replyAttachmentPath.value = '';
    replyAttachmentName.value = '';
  }
}