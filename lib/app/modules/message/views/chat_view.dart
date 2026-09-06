import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_event.dart';
import '../../../data/models/availability_model.dart';
import '../controllers/message_controller.dart';
import '../../main/controllers/main_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http; // নতুন
import 'package:path_provider/path_provider.dart'; // নতুন
import 'package:open_filex/open_filex.dart'; // নতুন
import '../../../core/widgets/responsive_layout.dart';

TimeOfDay? _parseOrderTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim().toUpperCase();
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*(AM|PM)?$')
      .firstMatch(value);
  if (match == null) return null;
  var hour = int.tryParse(match.group(1)!) ?? 0;
  final minute = int.tryParse(match.group(2)!) ?? 0;
  final period = match.group(3);
  if (period == 'PM' && hour < 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  if (hour > 23 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _displayOrderTime(BuildContext context, String? raw) {
  final parsed = _parseOrderTime(raw);
  if (parsed == null) return (raw == null || raw.trim().isEmpty) ? '—' : raw;
  return MaterialLocalizations.of(context).formatTimeOfDay(
    parsed,
    alwaysUse24HourFormat: false,
  );
}

String _displayOrderEndTime(BuildContext context, MessageModel msg) {
  if ((msg.endTime ?? '').trim().isNotEmpty) {
    return _displayOrderTime(context, msg.endTime);
  }
  final start = _parseOrderTime(msg.timeSlot);
  final hours = int.tryParse(RegExp(r'\d+').firstMatch(msg.duration ?? '')?.group(0) ?? '');
  if (start == null || hours == null) return '—';
  final totalMinutes = (start.hour * 60 + start.minute + hours * 60) % (24 * 60);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60),
    alwaysUse24HourFormat: false,
  );
}

class _OrderAttachmentsStrip extends StatelessWidget {
  final List<String> urls;
  const _OrderAttachmentsStrip({required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: 68.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          final url = urls[index];
          final isPdf = Uri.tryParse(url)?.path.toLowerCase().endsWith('.pdf') ??
              url.toLowerCase().contains('.pdf');
          return GestureDetector(
            onTap: isPdf
                ? null
                : () => Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(16.w),
                        child: InteractiveViewer(
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                      ),
                    ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: isPdf
                  ? Container(
                      width: 68.w,
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: Icon(Icons.picture_as_pdf,
                          color: Colors.red.shade400, size: 28.sp),
                    )
                  : Image.network(
                      url,
                      width: 68.w,
                      height: 68.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 68.w,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Counter-offer bottom sheet
// ─────────────────────────────────────────────────────────────
void showCounterOfferBottomSheet(
  BuildContext context,
  MessageModel msg,
  MessageController controller,
  ChatModel chat,
  String currentRole,
) {
  final priceController = TextEditingController();
  final messageController = TextEditingController();
  final budgetAmount = 0.0.obs;

  if (msg.proposedBudget != null) {
    priceController.text = msg.proposedBudget!.toStringAsFixed(0);
    budgetAmount.value = msg.proposedBudget!;
  } else if (msg.budget != null) {
    priceController.text = msg.budget!.toStringAsFixed(0);
    budgetAmount.value = msg.budget!;
  }

  priceController.addListener(() {
    budgetAmount.value = double.tryParse(priceController.text) ?? 0.0;
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Counteroffer".tr,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "Propose a new budget to the other party.".tr,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onEditingComplete: () =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              autofocus: true,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: r"$ ",
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final fee = budgetAmount.value * 0.20;
              final net = budgetAmount.value - fee;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Platform Fee (20%):".tr,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        "-\$${fee.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Net Amount:".tr,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${net.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            SizedBox(height: 24.h),
            Text(
              "Message / Description".tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter details about your proposal...".tr,
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  final message = messageController.text.trim();
                  if (price > 0 && message.isNotEmpty) {
                    final success = await controller.sendCounterOffer(
                      chat,
                      msg,
                      price,
                      currentRole,
                      message,
                    );
                    if (success) {
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    }
                  } else {
                    Get.snackbar("Error".tr, "Please enter a valid price and a message.".tr,
                      backgroundColor: Colors.red.shade100,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Send Counter".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
    },
  );
}

// ─────────────────────────────────────────────────────────────
// Propose New Time bottom sheet (Provider only).
// Called from PaymentCompletedCardWidget's "Propose New Time" button,
// which always passes widget.msg.orderId — the exact orderId that
// specific card represents. No scanning chat history, no guessing.
// ─────────────────────────────────────────────────────────────
void showProposeTimeBottomSheet(
  BuildContext context,
  int orderId,
  MessageController controller,
) {
  final selectedDate = Rxn<DateTime>();
  final selectedSlot = Rxn<String>();
  final descCtrl = TextEditingController();
  // ✅ Type is now DateSlot (matches fetchAvailableSlots' new return
  // type, which routes through AvailabilityRepository like MyJobView).
  final slots = <DateSlot>[].obs;
  final isLoadingSlots = false.obs;
  final slotsError = ''.obs;

  Future<void> loadSlots(DateTime date) async {
    isLoadingSlots.value = true;
    slotsError.value = '';
    slots.clear();
    selectedSlot.value = null;

    try {
      final available = await controller.fetchAvailableSlots(date);
      slots.assignAll(available);
      if (slots.isEmpty) {
        slotsError.value =
            'No available slots on this date.\nPlease choose another date or update your availability in Profile.'.tr;
      }
    } catch (e) {
      slotsError.value = 'Could not load slots. Please try again.'.tr;
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Get.bottomSheet(
    isScrollControlled: true,
    Obx(
      () => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    'Propose New Time'.tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Select one of your available slots. Client will Accept or Decline.'.tr,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    'Date'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate:
                            selectedDate.value ??
                            DateTime.now().add(Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFF6CA34D),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        selectedDate.value = picked;
                        await loadSlots(picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate.value != null
                                ? '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}'
                                : 'Tap to select a date'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: selectedDate.value != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18.sp,
                            color: Color(0xFF6CA34D),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (selectedDate.value != null) ...[
                    Text(
                      'Available Time Slots'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Builder(builder: (_) {
                      if (isLoadingSlots.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: CircularProgressIndicator(
                              color: Color(0xFF6CA34D),
                            ),
                          ),
                        );
                      }
                      if (slotsError.value.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  slotsError.value,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (slots.isEmpty) return SizedBox.shrink();

                      return Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: slots.map((s) {
                          // ✅ DateSlot has no separate start_time field —
                          // derive it from the label, e.g.
                          // "09:00 AM - 10:00 AM" → "09:00 AM". Same
                          // approach as MyJobView's slot picker.
                          final startTime = s.slot.split('-').first.trim();
                          final isSelected = selectedSlot.value == startTime;
                          return GestureDetector(
                            onTap: () => selectedSlot.value = startTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF6CA34D)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF6CA34D)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                startTime,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(height: 16.h),
                  ],

                  Text(
                    'Reason'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Why do you need to change the time?'.tr,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Color(0xFF6CA34D),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // ✅ async করুন
                        // --- ভ্যালিডেশন চেক ---
                        if (selectedDate.value == null) {
                          Get.snackbar('Missing'.tr, 'Please select a date.'.tr,
                            backgroundColor: Colors.red.shade100,
                          );
                          return; // শীট খোলা থাকবে
                        }
                        if (selectedSlot.value == null) {
                          Get.snackbar('Missing'.tr, 'Please select an available time slot.'.tr,
                            backgroundColor: Colors.red.shade100,
                          );
                          return;
                        }
                        if (descCtrl.text.trim().isEmpty) {
                          Get.snackbar('Missing'.tr, 'Please provide a reason.'.tr,
                            backgroundColor: Colors.red.shade100,
                          );
                          return;
                        }

                        // --- সব ঠিক থাকলে প্রথমে শীট বন্ধ করুন ---
                        final dateStr =
                            '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';

                        try {
                          final success =
                              await controller.proposeNewTimeFromOrder(
                            orderId,
                            dateStr,
                            selectedSlot.value!,
                            descCtrl.text.trim(),
                          );
                          if (success) {
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        } catch (e) {
                          // এরর হলে ইউজারকে জানান
                          Get.snackbar(
                            'Error'.tr,
                            'Propose failed'.trParams({
                              'error': e.toString(),
                            }),
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6CA34D),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Propose New Time'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Main Chat View
// ─────────────────────────────────────────────────────────────
class ChatView extends StatefulWidget {
  final ChatModel chat;
  ChatView({super.key, required this.chat});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  MessageController get _ctrl => Get.find<MessageController>();
  ChatModel get _chat => widget.chat;

  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Worker _messageListWorker;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> _staged = Rx<File?>(null);
  final RxBool _stagedIsPdf = false.obs;
  final RxBool _sending = false.obs;

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients && _chat.messages.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Live WS messages and order-card replacements rebuild the list after the
    // current frame. Scroll only then, so a new normal message is visibly
    // below the latest card just like it is after reopening the room.
    _messageListWorker = ever(_chat.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToBottomIfNeeded();
      });
    });
    if (_chat.roomUuid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.loadMessages(_chat);
        _ctrl.connectToChatRoom(_chat.roomUuid!);
        _scrollToBottomIfNeeded();
      });

      Future.delayed(Duration(milliseconds: 1200), () {
        if (mounted) {
          _ctrl.loadMessages(_chat);
          _scrollToBottomIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _messageListWorker.dispose();
    _inputCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    final file = _staged.value;

    if (file != null) {
      if (_sending.value) return;
      _sending.value = true;
      final ok = await _ctrl.sendAttachment(
        _chat,
        file,
        _stagedIsPdf.value ? 'file' : 'image',
        caption: text.isNotEmpty ? text : null,
      );
      _sending.value = false;
      if (ok) {
        _staged.value = null;
        _inputCtrl.clear();
        _scrollToBottomIfNeeded();
      }
      return;
    }

    if (text.isEmpty) return;
    _ctrl.sendMessage(_chat, text);
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottomIfNeeded();
    });
  }

  void _showAttachSheet() {
    if (_ctrl.isDeclined.value) return;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.h),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF6CA34D),
                  ),
                  title: Text("Take a photo".tr),
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.image_outlined,
                    color: Color(0xFF6CA34D),
                  ),
                  title: Text("Choose from gallery".tr),
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red.shade400,
                  ),
                  title: Text("Attach a PDF".tr),
                  onTap: () {
                    Get.back();
                    _pickPdf();
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 70);
      if (x != null) {
        _staged.value = File(x.path);
        _stagedIsPdf.value = false;
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not pick image.'.tr);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final path = r?.files.single.path;
      if (path != null) {
        _staged.value = File(path);
        _stagedIsPdf.value = true;
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not pick file.'.tr);
    }
  }

  // ────── নতুন মেথড: পিডিএফ / ফাইল ট্যাপ করলে অপশন শীট দেখানো ──────
  void _handleAttachmentTap(String url, String fileName, String? mime) {
    final isPdf =
        (mime?.contains('pdf') ?? false) ||
        fileName.toLowerCase().endsWith('.pdf');
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: Text(
                '${'Open'.tr} ${isPdf ? 'PDF' : 'File'.tr}',
              ),
              onTap: () {
                Get.back();
                _downloadAndOpenFile(
                  url,
                  fileName,
                  mime,
                  openAfterDownload: true,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppColors.primary),
              title: Text('Download'.tr),
              onTap: () {
                Get.back();
                _downloadAndOpenFile(
                  url,
                  fileName,
                  mime,
                  openAfterDownload: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ────── ফাইল ডাউনলোড ও ওপেন / ডাউনলোড সেভ ──────
  Future<void> _downloadAndOpenFile(
    String url,
    String fileName,
    String? mime, {
    required bool openAfterDownload,
  }) async {
    try {
      // ডাউনলোড
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        Get.snackbar("Error".tr, "Could not download file.".tr);
        return;
      }

      Directory dir;
      if (openAfterDownload) {
        // ওপেন করার জন্য টেম্প ফোল্ডার
        dir = await getTemporaryDirectory();
      } else {
        // ডাউনলোড সেভ করার জন্য ডিভাইস স্টোরেজে Download ফোল্ডার
        if (Platform.isAndroid) {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            dir = Directory('${extDir.path}/Download');
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
          } else {
            dir = await getApplicationDocumentsDirectory();
          }
        } else {
          // iOS: ডকুমেন্টস ডিরেক্টরি (Files app থেকে অ্যাক্সেসযোগ্য হয় যদি share sheet ব্যবহার করি,
          // কিন্তু এখানে সরাসরি সেভ করে ওপেন করাই যথেষ্ট)
          dir = await getApplicationDocumentsDirectory();
        }
      }

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (openAfterDownload) {
        // ফাইল ওপেন
        final result = await OpenFilex.open(filePath, type: mime);
        if (result.type != ResultType.done) {
          Get.snackbar("Error".tr, result.message);
        }
      } else {
        // ডাউনলোড শেষে সাথে সাথে ওপেনও করে দাও
        final openResult = await OpenFilex.open(filePath, type: mime);
        if (openResult.type != ResultType.done) {
          // ignore
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error".tr,
        "Failed to download file".trParams({'error': e.toString()}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 900,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
          _buildTopProfileSection(),
          Expanded(
            child: Obx(() {
              final messageList = _collapseByOrder(_chat.messages.toList());
              if (messageList.isEmpty) {
                return Center(
                  child: Text(
                    "No messages yet. Say hello!".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: 0,
                ),
                itemCount: messageList.length,
                itemBuilder: (context, index) =>
                    _buildMessageBubble(context, messageList[index]),
              );
            }),
          ),
          _buildInputArea(),
          ],
        ),
      ),
    );
  }

  List<MessageModel> _collapseByOrder(List<MessageModel> raw) {
    // The controller sorts its canonical list, but API replacement and a WS
    // frame can notify separate reactive mutations in the same render cycle.
    // Sort this local snapshot again by the exact same backend-id chronology
    // before collapsing. This is non-mutating for the controller list.
    raw.sort(_ctrl.compareMessageTimeline);

    // Controller already keeps one canonical order card. This is a defensive
    // collapse for API/WS races: choose the chronologically latest order item
    // and place it at that item's position, never at the first event position.
    final Map<int, MessageModel> latest = {};
    final Map<int, int> latestIndex = {};
    final Map<int, int> maxCounter = {};
    for (var index = 0; index < raw.length; index++) {
      final m = raw[index];
      if (m.orderId == null) continue;
      final oid = m.orderId!;
      final prevCnt = maxCounter[oid] ?? 0;
      maxCounter[oid] = m.counterCount > prevCnt ? m.counterCount : prevCnt;
      latest[oid] = m;
      latestIndex[oid] = index;
    }

    final List<MessageModel> out = [];
    for (var index = 0; index < raw.length; index++) {
      final m = raw[index];
      final oid = m.orderId;
      if (oid != null) {
        if (latestIndex[oid] != index) continue;
        final rep = latest[oid]!;
        rep.counterCount = maxCounter[oid] ?? rep.counterCount;
        out.add(rep);
      } else {
        out.add(m);
      }
    }
    return out;
  }

  Widget _buildTopProfileSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: Icon(Icons.arrow_back_ios),
              ),
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _chat.avatar.isNotEmpty
                    ? NetworkImage(_chat.avatar)
                    : null,
                child: _chat.avatar.isEmpty
                    ? Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chat.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Obx(() {
            final isClientMode =
                Get.find<MainController>().activePhase.value == 1;
            if (!isClientMode) return SizedBox.shrink();

            final hasPendingRequest = _chat.messages.any(
              (m) =>
                  (m.type == MessageType.offer ||
                      m.type == MessageType.quote) &&
                  m.senderRole == 'client' &&
                  (m.offerStatus == 'pending' || m.offerStatus == 'sent'),
            );

            if (!hasPendingRequest) return SizedBox.shrink();

            return Column(
              children: [
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  alignment: Alignment.center,
                  child: Text(
                    "STATUS: WAITING FOR RESPONSE".tr,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageModel msg) {
    if (msg.quoteExpiryTime != null &&
        DateTime.now().isAfter(msg.quoteExpiryTime!) &&
        msg.offerStatus == 'pending') {
      msg.offerStatus = 'expired';
    }

    final cancellationResponse = (msg.changesRequestStatus ?? '').toUpperCase();
    final cancellationWasDeclined =
        cancellationResponse == 'DECLINED' || cancellationResponse == 'DECLINE';
    if (msg.eventType == OrderEventType.orderCancel &&
        cancellationWasDeclined) {
      final restoredStatus = (msg.jobState ?? '').toUpperCase();
      msg.offerStatus = restoredStatus == 'IN_PROGRESS'
          ? 'inProgress'
          : restoredStatus == 'COMPLETED'
          ? 'completed'
          : 'paid';
    }

    final cancellationIsPending =
        cancellationResponse.isEmpty ||
        cancellationResponse == 'PENDING' ||
        cancellationResponse == 'NO_RESPONSE';
    if (msg.eventType == OrderEventType.orderCancel &&
        msg.offerStatus == 'cancellationRequested' &&
        cancellationIsPending) {
      return SystemEventCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    // Status wins over wire event type. Work-start, set-hours, completion and
    // review events update the same full order card instead of rendering a
    // separate compact SystemEventCardWidget.
    if (msg.offerStatus == 'paid' ||
        msg.offerStatus == 'inProgress' ||
        msg.offerStatus == 'completed') {
      return PaymentCompletedCardWidget(
        msg: msg,
        controller: _ctrl,
        chat: _chat,
      );
    }
    if (msg.offerStatus == 'accepted') {
      final isClientMode = Get.find<MainController>().activePhase.value == 1;
      return QuoteAcceptedWidget(
        msg: msg,
        controller: _ctrl,
        chat: _chat,
        isClient: isClientMode,
      );
    }
    if (msg.type == MessageType.offer || msg.type == MessageType.quote) {
      return NegotiationCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    // Cancellation/time-change requests need their event-specific response
    // controls, but remain one canonical item because MessageController
    // collapses by orderId before this point.
    if (msg.type == MessageType.systemEvent) {
      return SystemEventCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    if (msg.type == MessageType.image ||
        msg.type == MessageType.file ||
        msg.type == MessageType.video ||
        msg.type == MessageType.audio) {
      return _buildAttachmentBubble(msg);
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: msg.isMe ? Color(0xFFF2FBF0) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: msg.isMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : Radius.circular(16.r),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.sp,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble(MessageModel msg) {
    final url = msg.attachmentUrl;
    final hasUrl = url != null && url.isNotEmpty;
    final isImage = msg.type == MessageType.image;

    final attachmentWidth = (MediaQuery.sizeOf(context).width * 0.58)
        .clamp(180.0, 280.0)
        .toDouble();
    Widget media;
    if (isImage && hasUrl) {
      media = ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: GestureDetector(
          onTap: () => _openImageFullScreen(url),
          child: Image.network(
            url,
            width: attachmentWidth,
            fit: BoxFit.cover,
            loadingBuilder: (c, child, progress) => progress == null
                ? child
                : Container(
                    width: attachmentWidth,
                    height: 160,
                    alignment: Alignment.center,
                    color: Colors.grey.shade100,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
            errorBuilder: (c, e, s) => Container(
              width: attachmentWidth,
              height: 120,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image,
                color: Colors.grey.shade400,
                size: 32.sp,
              ),
            ),
          ),
        ),
      );
    } else {
      final name = msg.attachmentName ?? 'Attachment'.tr;
      final isPdf =
          name.toLowerCase().endsWith('.pdf') ||
          (msg.attachmentMime ?? '').contains('pdf');
      media = GestureDetector(
        // <-- নতুন GestureDetector
        onTap: hasUrl
            ? () => _handleAttachmentTap(url!, name, msg.attachmentMime)
            : null,
        child: Container(
          width: attachmentWidth,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? Colors.red.shade400 : Color(0xFF6CA34D),
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            media,
            if (msg.text.trim().isNotEmpty) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Color(0xFFF2FBF0)
                      : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openImageFullScreen(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Staged attachment preview
            Obx(() {
              final f = _staged.value;
              if (f == null) return SizedBox.shrink();
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF2FBF0),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: _stagedIsPdf.value
                          ? Container(
                              width: 48.w,
                              height: 48.h,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red.shade400,
                                size: 26.sp,
                              ),
                            )
                          : Image.file(
                              f,
                              width: 48.w,
                              height: 48.h,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        f.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                      onPressed: () => _staged.value = null,
                    ),
                  ],
                ),
              );
            }),

            // Message input row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                  onPressed: _showAttachSheet,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Obx(() {
                      final isDeclinedState = _ctrl.isDeclined.value;
                      return TextField(
                        controller: _inputCtrl,
                        enabled: !isDeclinedState,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: (isDeclinedState
                                  ? "Chat deactivated"
                                  : "Type a message...")
                              .tr,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: Color(0xFF6A9B5D),
                  radius: 22.r,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18.sp),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Negotiation card (real data, both roles)
// ─────────────────────────────────────────────────────────────
class NegotiationCardWidget extends StatefulWidget {
  final MessageModel msg;
  final MessageController controller;
  final ChatModel chat;

  NegotiationCardWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.chat,
  });

  @override
  State<NegotiationCardWidget> createState() => _NegotiationCardWidgetState();
}

class _NegotiationCardWidgetState extends State<NegotiationCardWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.msg.orderId != null && widget.msg.orderAttachments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadOrderAttachments(widget.msg);
      });
    }
  }

  void _openImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClientMode = Get.find<MainController>().activePhase.value == 1;
    final currentRole = isClientMode ? 'client' : 'provider';

    final isSender = widget.msg.senderRole == currentRole;
    final hasCounterMsg =
        widget.msg.counterMessage != null &&
        widget.msg.counterMessage!.isNotEmpty;
    final isTimeChange = widget.msg.isRescheduleRequest;
    final double price = widget.msg.proposedBudget ?? widget.msg.budget ?? 0.0;
    final isPending =
        widget.msg.offerStatus == 'pending' || widget.msg.offerStatus == 'sent';
    final isCancelled = widget.msg.offerStatus == 'cancelled';
    final isDeclined = widget.msg.offerStatus == 'declined';

    final int counterCount = widget.msg.counterCount;
    final bool lastWasClient = widget.msg.senderRole == 'client';

    final bool providerTurn = !isClientMode && lastWasClient;
    final bool clientTurn = isClientMode && !lastWasClient;
    final bool myTurn = providerTurn || clientTurn;

    final bool providerCanCounter = providerTurn && counterCount == 0;
    final bool clientCanCounter = clientTurn && counterCount == 1;
    final bool canCounter = providerCanCounter || clientCanCounter;

    String headerText = "NEW JOB REQUEST";
    Color headerBgColor = Color(0xFFF9F9F9);
    Color headerTextColor = Colors.black87;
    IconData headerIcon = Icons.request_quote_outlined;
    Color iconColor = AppColors.primary;

    if (isTimeChange) {
      headerText = isSender
          ? "YOUR TIME CHANGE REQUEST"
          : "TIME CHANGE REQUEST";
      headerBgColor = isSender ? Colors.purple.shade50 : Colors.purple.shade100;
      headerTextColor = Colors.purple.shade900;
      iconColor = Colors.purple.shade700;
      headerIcon = Icons.update;
    } else if (hasCounterMsg || counterCount > 0) {
      headerText = counterCount >= 2
          ? "COUNTER OFFER (FINAL)"
          : (isSender ? "YOUR COUNTER OFFER" : "COUNTER OFFER RECEIVED");
      headerBgColor = Colors.orange.shade50;
      headerTextColor = Colors.orange.shade900;
      iconColor = Colors.orange.shade800;
      headerIcon = Icons.handshake_outlined;
    } else if (isSender) {
      headerText = "SENT REQUEST SUMMARY";
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        width: (MediaQuery.sizeOf(context).width * 0.88)
            .clamp(280.0, 760.0)
            .toDouble(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(headerIcon, size: 18.sp, color: iconColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      headerText.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: headerTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (isPending && !myTurn)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "WAITING".tr,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: headerTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.build_circle,
                          color: Colors.grey,
                          size: 30.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.msg.taskTitle ?? 'Task Details'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  widget.msg.clientRating?.toString() ?? "—",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  if (isTimeChange) ...[
                    _infoRow(
                      Icons.history,
                      "Old Time".trParams({
                        'time': widget.msg.timeSlot ?? '—',
                      }),
                      strike: true,
                    ),
                    SizedBox(height: 6.h),
                    _infoRow(
                      Icons.update,
                      "New Time".trParams({
                        'time': widget.msg.proposedTimeSlot ?? '—',
                      }),
                    ),
                  ] else ...[
                    _infoRow(
                      Icons.calendar_today_outlined,
                      widget.msg.date?.toString().split(' ')[0] ?? 'Date'.tr,
                    ),
                    SizedBox(height: 6.h),
                    _infoRow(
                      Icons.play_circle_outline,
                      "Start Time Value".trParams({
                        'time': _displayOrderTime(
                          context,
                          widget.msg.timeSlot,
                        ),
                      }),
                    ),
                    SizedBox(height: 6.h),
                    _infoRow(
                      Icons.stop_circle_outlined,
                      "End Time Value".trParams({
                        'time': _displayOrderEndTime(context, widget.msg),
                      }),
                    ),
                  ],

                  SizedBox(height: 6.h),
                  _infoRow(
                    Icons.location_on_outlined,
                    widget.msg.address ?? "Location".tr,
                  ),
                  SizedBox(height: 6.h),
                  _infoRow(
                    Icons.schedule_outlined,
                    "Booking Duration".trParams({
                      'duration': widget.msg.duration ?? '—',
                    }),
                  ),
                  SizedBox(height: 6.h),
                  _infoRow(
                    Icons.payments_outlined,
                    "Budget Value".trParams({
                      'amount': '\$${price.toStringAsFixed(0)}',
                    }),
                    isBold: true,
                  ),
                  SizedBox(height: 16.h),

                  Text(
                    "Job Description".tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.msg.description ?? "Please review details.".tr,
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        _isExpanded ? "See less".tr : "See more".tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (widget.msg.orderAttachments.isNotEmpty) ...[
                    SizedBox(
                      height: 64.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.msg.orderAttachments.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (_, i) {
                          final url = widget.msg.orderAttachments[i];
                          final isPdf =
                              Uri.tryParse(url)?.path.toLowerCase().endsWith('.pdf') ??
                              url.toLowerCase().contains('.pdf');
                          return GestureDetector(
                            onTap: isPdf ? null : () => _openImage(url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: isPdf
                                  ? Container(
                                      width: 64.w,
                                      height: 64.h,
                                      color: Colors.grey.shade100,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red.shade400,
                                        size: 26.sp,
                                      ),
                                    )
                                  : Image.network(
                                      url,
                                      width: 64.w,
                                      height: 64.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 64.w,
                                        height: 64.h,
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey.shade400,
                                          size: 22.sp,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  if (hasCounterMsg && widget.msg.counterMessage != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: isTimeChange
                            ? Colors.purple.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        // Flutter cannot paint a rounded Border with
                        // non-uniform side colors/widths.
                        border: Border.all(
                          color: isTimeChange
                              ? Colors.purple.shade300
                              : Colors.orange.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (isTimeChange
                                    ? "Reason for Time Change:"
                                    : "Message:")
                                .tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: isTimeChange
                                  ? Colors.purple.shade900
                                  : Colors.orange.shade900,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "\"${widget.msg.counterMessage}\"",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status / Action buttons
                  if (isCancelled)
                    _statusBanner("REQUEST CANCELLED", Colors.grey)
                  else if (isDeclined)
                    _statusBanner("OFFER DECLINED", Colors.red)
                  else if (isPending && myTurn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            "Accept",
                            Color(0xFF4CAF50),
                            () => widget.controller.onAcceptQuote(
                              widget.msg,
                              widget.chat,
                            ),
                          ),
                        ),
                        if (canCounter) ...[
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _actionBtn(
                              "Counter",
                              Color(0xFF9E9E9E),
                              () => showCounterOfferBottomSheet(
                                context,
                                widget.msg,
                                widget.controller,
                                widget.chat,
                                currentRole,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _actionBtn(
                      "Decline",
                      Colors.white,
                      () => widget.controller.onDeclineQuote(
                        widget.msg,
                        widget.chat,
                      ),
                      isOutlined: true,
                      textColor: Colors.red,
                    ),
                  ] else if (isPending &&
                      isClientMode &&
                      counterCount == 0) ...[
                    _actionBtn(
                      "Cancel Request",
                      Colors.white,
                      () => widget.controller.cancelRequest(
                        widget.msg,
                        widget.chat,
                      ),
                      isOutlined: true,
                      textColor: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: isOutlined
              ? BorderSide(color: textColor ?? Colors.grey.shade400)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          label.tr,
          style: TextStyle(
            color: isOutlined ? (textColor ?? Colors.black87) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    bool isBold = false,
    bool strike = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: isBold ? Colors.black87 : AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isBold ? Colors.black87 : AppColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Accepted / Awaiting Payment card
// ─────────────────────────────────────────────────────────────
class QuoteAcceptedWidget extends StatefulWidget {
  final MessageModel msg;
  final MessageController controller;
  final ChatModel chat;
  final bool isClient;

  QuoteAcceptedWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.chat,
    this.isClient = true,
  });

  @override
  State<QuoteAcceptedWidget> createState() => _QuoteAcceptedWidgetState();
}

class _QuoteAcceptedWidgetState extends State<QuoteAcceptedWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.msg.orderId != null && widget.msg.orderAttachments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadOrderAttachments(widget.msg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.msg.proposedBudget ?? widget.msg.budget ?? 0.0;
    final isPaid = widget.msg.offerStatus == 'paid';

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h, top: 8.h),
        width: (MediaQuery.sizeOf(context).width * 0.9)
            .clamp(280.0, 760.0)
            .toDouble(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Color(0xFF4CAF50), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              ),
              child: Text(
                (isPaid
                        ? "STATUS: PAID SECURELY"
                        : "STATUS: AWAITING PAYMENT")
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.build_circle,
                          color: Colors.grey,
                          size: 36.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.msg.taskTitle ?? 'Task Details'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  widget.msg.clientRating?.toString() ?? "—",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "JOB SUMMARY".tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        _summaryItem(
                          "Category:",
                          widget.msg.category ?? "General",
                        ),
                        SizedBox(height: 8.h),
                        _summaryItem(
                          "Date:",
                          widget.msg.date?.toString().split(' ')[0] ??
                              "Date Not Set".tr,
                        ),
                        SizedBox(height: 8.h),
                        _summaryItem(
                          "Start Time:",
                          _displayOrderTime(context, widget.msg.timeSlot),
                        ),
                        SizedBox(height: 8.h),
                        _summaryItem(
                          "End Time:",
                          _displayOrderEndTime(context, widget.msg),
                        ),
                        SizedBox(height: 8.h),
                        _summaryItem("Duration:", widget.msg.duration ?? "—"),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Job Description".tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.msg.description ?? "No description provided.".tr,
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        _isExpanded ? "See less".tr : "See more".tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  if (widget.msg.orderAttachments.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _OrderAttachmentsStrip(
                      urls: widget.msg.orderAttachments,
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        "Final Price".trParams({
                          'amount': '\$${total.toStringAsFixed(2)}',
                        }),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  if (!isPaid) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Color(0xFFFFECB3)),
                      ),
                      child: Text(
                        "Cancellation Policy: Full refund if cancelled 24h before job start; 50% refund after 24h.".tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF795548),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (widget.isClient) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => widget.controller.processPayment(
                            widget.msg,
                            widget.chat,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Pay and Confirm".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Center(
                        child: TextButton(
                          onPressed: () => widget.controller.cancelRequest(
                            widget.msg,
                            widget.chat,
                          ),
                          child: Text(
                            "Cancel Booking".tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hourglass_top,
                              color: Colors.amber.shade800,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                "Waiting for the client to pay.".tr,
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => widget.controller.cancelRequest(
                            widget.msg,
                            widget.chat,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent),
                          ),
                          child: Text(
                            'Cancel Booking'.tr,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8.w),
                          Text(
                            "Payment Completed".tr,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (!widget.isClient &&
                        widget.msg.orderId != null &&
                        !widget.msg.hoursSet)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showSetHoursDialog(
                            context,
                            widget.msg.orderId!,
                            widget.controller,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Set Hours".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment Completed card
// ─────────────────────────────────────────────────────────────
class PaymentCompletedCardWidget extends StatefulWidget {
  final MessageModel? msg;
  final MessageController controller;
  final ChatModel chat;

  PaymentCompletedCardWidget({
    super.key,
    this.msg,
    required this.controller,
    required this.chat,
  });

  @override
  State<PaymentCompletedCardWidget> createState() =>
      _PaymentCompletedCardWidgetState();
}

class _PaymentCompletedCardWidgetState
    extends State<PaymentCompletedCardWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final msg = widget.msg;
    if (msg?.orderId != null && msg!.orderAttachments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadOrderAttachments(msg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total =
        widget.msg?.proposedBudget ?? widget.msg?.budget ?? 0.0;
    final isClientMode = Get.find<MainController>().activePhase.value == 1;
    final isCompleted =
        widget.msg?.offerStatus == 'completed' ||
        (widget.msg?.workCompleted ?? false) ||
        (widget.msg?.feedbackGiven ?? false) ||
        widget.msg?.eventType == OrderEventType.orderCompleted;
    final statusLabel = isCompleted
        ? 'STATUS: WORK COMPLETED'
        : widget.msg?.offerStatus == 'inProgress'
        ? 'STATUS: WORK IN PROGRESS'
        : 'STATUS: PAID SECURELY';
    final stateBadge = isCompleted
        ? 'Work Completed'
        : widget.msg?.offerStatus == 'inProgress'
        ? 'Work In Progress'
        : 'Payment Completed';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Center(
              child: Text(
                statusLabel.tr,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.build_circle,
                        color: Colors.grey,
                        size: 36.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.msg?.taskTitle ?? 'Task Details'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Row(
                          //   children: [
                          //     Icon(Icons.star,
                          //         size: 16.sp, color: Colors.amber),
                          //     SizedBox(width: 4.w),
                          //     Text(
                          //         widget.msg?.clientRating?.toString() ??
                          //             "—",
                          //         style: TextStyle(
                          //             fontSize: 13.sp,
                          //             color: Colors.grey.shade700,
                          //             fontWeight: FontWeight.w600)),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      // _summaryRow(Icons.work_outline,
                      //     "Category: ${widget.msg?.category ?? "—"}"),
                      SizedBox(height: 8.h),
                      _summaryRow(
                        Icons.calendar_today_outlined,
                        "Date Value".trParams({
                          'date':
                              widget.msg?.date?.toString().split(' ')[0] ?? "—",
                        }),
                      ),
                      SizedBox(height: 8.h),
                      _summaryRow(
                        Icons.play_circle_outline,
                        "Start Time Value".trParams({
                          'time': _displayOrderTime(
                            context,
                            widget.msg?.timeSlot,
                          ),
                        }),
                      ),
                      SizedBox(height: 8.h),
                      _summaryRow(
                        Icons.stop_circle_outlined,
                        "End Time Value".trParams({
                          'time': widget.msg == null
                              ? '—'
                              : _displayOrderEndTime(context, widget.msg!),
                        }),
                      ),
                      SizedBox(height: 8.h),
                      _summaryRow(
                        Icons.access_time,
                        "Duration Value".trParams({
                          'duration': widget.msg?.duration ?? "—",
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Job Description".tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.msg?.description ?? "No description provided.".tr,
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      _isExpanded ? "See less".tr : "See more".tr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                if (widget.msg?.orderAttachments.isNotEmpty == true) ...[
                  SizedBox(height: 12.h),
                  _OrderAttachmentsStrip(
                    urls: widget.msg!.orderAttachments,
                  ),
                ],
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    "Final Price".trParams({
                      'amount': '\$${total.toStringAsFixed(2)}',
                    }),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          stateBadge.tr,
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildLifecycleSection(isClientMode),
                if (widget.msg?.eventType == OrderEventType.orderWorkStart ||
                    widget.msg?.eventType == OrderEventType.orderCompleted ||
                    widget.msg?.eventType == OrderEventType.orderHourSet)
                  SizedBox(height: 16.h),
                if (!isClientMode &&
                    widget.msg?.orderId != null &&
                    widget.msg?.offerStatus == 'paid')
                  Row(
                    children: [
                      if (!(widget.msg?.hoursSet ?? false))
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showSetLogHoursBottomSheet(
                              context,
                              widget.msg!.orderId!,
                              widget.controller,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Set Hours".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      // if (!(widget.msg?.hoursSet ?? false))
                      //   SizedBox(width: 10.w),
                      // Expanded(
                      //   child: OutlinedButton(
                      //     onPressed: () => showProposeTimeBottomSheet(
                      //         context,
                      //         widget.msg!.orderId!,
                      //         widget.controller),
                      //     style: OutlinedButton.styleFrom(
                      //       padding: EdgeInsets.symmetric(vertical: 14.h),
                      //       side: BorderSide(
                      //           color: Color(0xFF6CA34D)),
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius:
                      //           BorderRadius.circular(12.r)),
                      //     ),
                      //     child: Text("Propose New Time".tr,
                      //         style: TextStyle(
                      //             color: Color(0xFF6CA34D),
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 14.sp)),
                      //   ),
                      // ),
                    ],
                  ),
                if (widget.msg?.orderId != null && !isCompleted) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.controller.cancelRequest(
                        widget.msg!,
                        widget.chat,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Request Cancellation'.tr,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Color(0xFF757575)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLifecycleSection(bool isClientMode) {
    final msg = widget.msg;
    if (msg == null) return SizedBox.shrink();

    if (msg.eventType == OrderEventType.orderWorkStart) {
      if (isClientMode) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Color(0xFFF7FBF4),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Color(0xFFCBE3B4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work started'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Share this confirmation code with the provider.'.tr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                msg.confirmationOtp?.isNotEmpty == true
                    ? msg.confirmationOtp!
                    : 'Loading code…'.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      RegExp(r'^\d{6}$').hasMatch(msg.confirmationOtp ?? '')
                      ? 22.sp
                      : 13.sp,
                  letterSpacing:
                      RegExp(r'^\d{6}$').hasMatch(msg.confirmationOtp ?? '')
                      ? 4
                      : 0,
                ),
              ),
            ],
          ),
        );
      }
      final orderId = msg.orderId;
      return _OtpEntry(
        onSubmit: (otp) async {
          if (orderId == null) return false;
          return widget.controller.completeWorkWithOtp(orderId, otp);
        },
      );
    }

    if (msg.eventType == OrderEventType.orderHourSet) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Color(0xFFF7FBF4),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          msg.proposedHour == null
              ? 'Estimated hours updated'.tr
              : 'Estimated hours updated to'.trParams({
                  'hours': '${msg.proposedHour}',
                }),
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      );
    }

    if (msg.eventType == OrderEventType.orderCompleted && msg.orderId != null) {
      if (msg.feedbackGiven) {
        return Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Thanks for your feedback!'.tr,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        );
      }
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: "Rate & Review".tr,
          onPressed: () => _openFeedbackDialog(msg.orderId!),
        ),
      );
    }

    return SizedBox.shrink();
  }

  void _openFeedbackDialog(int orderId) {
    final rating = 5.obs;
    final reviewController = TextEditingController();
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Rate & Review'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: () => rating.value = value,
                    icon: Icon(
                      value <= rating.value ? Icons.star : Icons.star_border,
                    ),
                    color: Color(0xFFFFB400),
                  );
                }),
              ),
            ),
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience…'.tr,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              final success = await widget.controller.submitFeedback(

                  orderId, rating.value, reviewController.text.trim());

              if (success) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Submit'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Set-hours dialogs
// ─────────────────────────────────────────────────────────────
void _showSetHoursDialog(
  BuildContext context,
  int orderId,
  MessageController controller,
) {
  final hoursCtrl = TextEditingController();
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set Hours Worked".tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Enter the actual hours needed for this task.".tr,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 24),
            TextField(
              controller: hoursCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: "hrs".tr,
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final hours = int.tryParse(hoursCtrl.text);
                  if (hours != null && hours > 0) {
                    final success = await controller.setWorkHour(
                      orderId,
                      hours,
                    );
                    if (success) {
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    }
                  } else {
                    Get.snackbar("Error".tr, "Please enter a valid number of hours.".tr,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showSetLogHoursBottomSheet(
  BuildContext context,
  int orderId,
  MessageController controller,
) {
  final selectedHours = Rxn<String>();
  final notesCtrl = TextEditingController();

  Get.bottomSheet(
    isScrollControlled: true,
    Obx(
      () => Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Set Logged Hours".tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "Set the work hours required for this task".tr,
                    style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  "Select Hours".tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedHours.value,
                  hint: Text(
                    "Select hours".tr,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            "Hours Count".trParams({'count': v}),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedHours.value = v,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Additional Notes (Optional)".tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter details about the work performed...".tr,
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final hours = int.tryParse(selectedHours.value ?? '');
                      if (hours == null) {
                        Get.snackbar("Error".tr, "Please select the hours worked.".tr,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      final success = await controller.setWorkHour(
                        orderId,
                        hours,
                        message: notesCtrl.text.trim().isNotEmpty
                            ? notesCtrl.text.trim()
                            : null,
                      );
                      if (success) {
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6DA54B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Confirm Hours".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// System-event card
// ─────────────────────────────────────────────────────────────
class SystemEventCardWidget extends StatelessWidget {
  final MessageModel msg;
  final MessageController controller;
  final ChatModel chat;

  SystemEventCardWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.chat,
  });

  bool get _isClient => Get.find<MainController>().activePhase.value == 1;

  @override
  Widget build(BuildContext context) {
    final body = _bodyForEvent();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Color(0xFFF7FBF4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Text(
              msg.taskTitle ?? 'Order update'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.date != null)
                  _sub(
                    'Date Value'.trParams({
                      'date': msg.date?.toString().split(' ')[0] ?? '—',
                    }),
                  ),
                if ((msg.timeSlot ?? '').isNotEmpty)
                  _sub(
                    'Start Time Value'.trParams({
                      'time': _displayOrderTime(context, msg.timeSlot),
                    }),
                  ),
                if ((msg.timeSlot ?? '').isNotEmpty ||
                    (msg.endTime ?? '').isNotEmpty)
                  _sub(
                    'End Time Value'.trParams({
                      'time': _displayOrderEndTime(context, msg),
                    }),
                  ),
                if ((msg.address ?? '').isNotEmpty)
                  _sub(
                    'Location Value'.trParams({
                      'location': msg.address ?? '',
                    }),
                  ),
                if (msg.proposedBudget != null || msg.budget != null)
                  _sub(
                    'Budget Value'.trParams({
                      'amount':
                          '\$${(msg.proposedBudget ?? msg.budget ?? 0).toStringAsFixed(0)}',
                    }),
                  ),
                if ((msg.description ?? '').isNotEmpty) _sub(msg.description!),
                Divider(height: 24),
                body,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyForEvent() {
    switch (msg.eventType) {
      case OrderEventType.orderWorkStart:
        return _workStartBody();
      case OrderEventType.orderCompleted:
        return _completedBody();
      case OrderEventType.orderCancel:
        return _cancelBody();
      // ✅ NOTE: ORDER_CHANGE_REQUEST (time change) is now handled by the
      // order card in OrderView, not here. We still render a lightweight
      // informational summary in chat for context, but Accept/Decline
      // buttons live only on the order card (single source of truth for
      // which orderId the action applies to).
      case OrderEventType.orderChangeRequest:
        return _timeChangeBody();
      case OrderEventType.orderHourSet:
        return _hourSetBody();
      default:
        return _genericBody();
    }
  }

  Widget _title(String t) => Text(
    t,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: AppColors.textPrimary,
    ),
  );

  Widget _sub(String t) => Padding(
    padding: EdgeInsets.only(top: 4),
    child: Text(
      t,
      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
    ),
  );

  Widget _genericBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_title(msg.text)],
  );

  Widget _workStartBody() {
    if (msg.workCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF6DA54B),
                size: 20,
              ),
              SizedBox(width: 8),
              _title('Work completed'.tr),
            ],
          ),
          _sub('This job has been marked complete.'.tr),
        ],
      );
    }
    if (_isClient) {
      final otp = msg.confirmationOtp;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Work started'.tr),
          _sub(
            'Share this 6-digit code with the helper to confirm completion.'.tr,
          ),
          SizedBox(height: 12),
          if (otp != null && otp.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF6DA54B)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                otp,
                style: TextStyle(
                  fontSize: RegExp(r'^\d{6}$').hasMatch(otp) ? 24 : 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: RegExp(r'^\d{6}$').hasMatch(otp) ? 6 : 0,
                  color: Color(0xFF6DA54B),
                ),
              ),
            )
          else
            Text(
              'Loading code…'.tr,
              style: TextStyle(color: AppColors.textSecondary),
            ),
        ],
      );
    }
    final orderId = msg.orderId;
    return _OtpEntry(
      onSubmit: (otp) async {
        if (orderId == null) return false;
        // ✅ Now properly awaits and forwards the real success/failure
        // result instead of firing-and-forgetting.
        return controller.completeWorkWithOtp(orderId, otp);
      },
    );
  }

  Widget _completedBody() {
    final orderId = msg.orderId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Work completed'.tr),
        if (_isClient && orderId != null) ...[
          if (msg.feedbackGiven) ...[
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF6DA54B), size: 18),
                SizedBox(width: 6),
                Text(
                  'Thanks for your feedback!'.tr,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ] else ...[
            _sub('How was your experience?'.tr),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openFeedbackDialog(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6DA54B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Rate & Review'.tr),
            ),
          ],
        ],
      ],
    );
  }

  Widget _cancelBody() {
    final status = msg.offerStatus;
    final isPending = status == 'cancellationRequested' || status == 'pending';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          (status == 'cancelled'
                  ? 'Order cancelled'
                  : 'Cancellation requested')
              .tr,
        ),
        if ((msg.proposedMessage ?? '').isNotEmpty)
          _sub(
            'Reason Value'.trParams({
              'reason': msg.proposedMessage ?? '',
            }),
          ),
        if (isPending && !msg.isMe) ...[
          SizedBox(height: 12),
          _AcceptDeclineRow(
            onAccept: () =>
                controller.respondToCancellation(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.respondToCancellation(msg, chat, 'DECLINED'),
          ),
        ],
      ],
    );
  }

  // ✅ RESTORED: Accept/Decline now lives in BOTH places — the order
  // card (OrderView/MyJobView) AND here in chat. This card is bound to
  // a SPECIFIC event message (msg.orderId, msg.changesRequestId come
  // straight from that one WebSocket/API event) — so there's no risk
  // of the "wrong order id" bug from before, which came from scanning
  // chat HISTORY to guess which order a button should act on. Here we
  // already know exactly which request this card represents.
  Widget _timeChangeBody() {
    final date = msg.proposedDateStr;
    final time = msg.proposedTime;
    final responded =
        msg.offerStatus == 'accepted' || msg.offerStatus == 'declined';
    final hasRequestId = msg.changesRequestId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 18,
              color: Colors.purple.shade700,
            ),
            SizedBox(width: 8),
            _title('New time proposed'.tr),
          ],
        ),
        if (date != null && date.isNotEmpty)
          _sub('Date Value'.trParams({'date': date})),
        if (time != null && time.isNotEmpty)
          _sub('Time Value'.trParams({'time': time})),
        if ((msg.proposedMessage ?? '').isNotEmpty)
          _sub(
            'Reason Value'.trParams({
              'reason': msg.proposedMessage ?? '',
            }),
          ),

        if (responded) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: msg.offerStatus == 'accepted'
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  msg.offerStatus == 'accepted'
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 16,
                  color: msg.offerStatus == 'accepted'
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(width: 6),
                Text(
                  (msg.offerStatus == 'accepted'
                          ? 'Time change accepted'
                          : 'Time change declined')
                      .tr,
                  style: TextStyle(
                    color: msg.offerStatus == 'accepted'
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ]
        // ✅ Only the CLIENT responds (provider sent it, so !msg.isMe
        // means "this is the other side's card" for the client).
        else if (_isClient && !msg.isMe && hasRequestId) ...[
          SizedBox(height: 12),
          _AcceptDeclineRow(
            onAccept: () => controller.respondToTimeChange(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.respondToTimeChange(msg, chat, 'DECLINED'),
          ),
        ] else if (_isClient && !msg.isMe && !hasRequestId) ...[
          _sub(
            'Cannot respond — request ID missing. Please pull to refresh.'.tr,
          ),
        ] else ...[
          // Provider sees their own sent request, or it's pending on
          // the other side — just show the waiting state.
          SizedBox(height: 4),
          _sub(
            (_isClient
                ? 'Waiting for your response — see above, or check your Orders tab.'
                : 'Waiting for the client to respond.')
                .tr,
          ),
        ],
      ],
    );
  }

  Widget _hourSetBody() {
    final isPending = msg.offerStatus == 'pending';
    final hour = msg.proposedHour;
    final hasRequestId = msg.changesRequestId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 18, color: Color(0xFF6DA54B)),
            SizedBox(width: 8),
            _title('Updated estimated hours'.tr),
          ],
        ),
        if (hour != null)
          _sub(
            'New Estimate Hours'.trParams({'count': '$hour'}),
          ),
        if ((msg.proposedMessage ?? '').isNotEmpty) _sub(msg.proposedMessage!),
        if (isPending && _isClient && hasRequestId) ...[
          SizedBox(height: 12),
          _AcceptDeclineRow(
            onAccept: () => controller.confirmHourChange(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.confirmHourChange(msg, chat, 'DECLINED'),
          ),
        ] else if (isPending && _isClient && !hasRequestId) ...[
          _sub('Cannot respond — request ID missing. Please refresh.'.tr),
        ] else if (isPending && !_isClient) ...[
          _sub('Waiting for client to confirm hours…'.tr),
        ],
      ],
    );
  }

  void _openFeedbackDialog(int orderId) {
    final rating = 5.obs;
    final reviewCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Rate & Review'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  return IconButton(
                    onPressed: () => rating.value = value,
                    icon: Icon(
                      value <= rating.value ? Icons.star : Icons.star_border,
                      color: Color(0xFFFFB400),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: reviewCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience…'.tr,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.submitFeedback(
                orderId,
                rating.value,
                reviewCtrl.text.trim(),
              );
              if (success) {
                final overlayContext = Get.overlayContext;
                if (overlayContext != null && overlayContext.mounted) {
                  Navigator.of(overlayContext, rootNavigator: true).pop();
                }
              }
            },
            child: Text('Submit'.tr),
          ),
        ],
      ),
    );
  }
}

class _AcceptDeclineRow extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _AcceptDeclineRow({required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6DA54B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Accept'.tr),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Decline'.tr),
          ),
        ),
      ],
    );
  }
}

// ✅ FIX: previously onSubmit was `void Function(String otp)` — pure
// fire-and-forget. The widget called it and moved on immediately, with
// no idea whether the backend actually accepted the OTP. On a WRONG
// OTP, the controller's error snackbar fired correctly, but this
// widget had no concept of "submission failed" — so nothing here
// prevented the surrounding card from looking/behaving as if the job
// had completed. Now onSubmit returns a Future<bool>, and this widget:
//   - disables the button + shows a spinner while the request is in flight
//   - on success (true): leaves it to the parent rebuild (msg.workCompleted
//     flips to true via _setOrderFlag, which swaps this card out)
//   - on failure (false): re-enables the button, KEEPS the entered code
//     visible (so the provider can see what they typed and fix a typo),
//     and shows an inline error — the job is never treated as complete.
class _OtpEntry extends StatefulWidget {
  final Future<bool> Function(String otp) onSubmit;

  const _OtpEntry({required this.onSubmit});

  @override
  State<_OtpEntry> createState() => _OtpEntryState();
}

class _OtpEntryState extends State<_OtpEntry> {
  final _ctrl = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final otp = _ctrl.text.trim();
    if (otp.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit code.'.tr);
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final success = await widget.onSubmit(otp);

    if (!mounted) return;

    if (success) {
      // Don't touch local state further — the parent will swap this
      // whole card out once msg.workCompleted flips to true.
      return;
    }

    // ✅ Wrong OTP / failure: stay on this screen, re-enable the
    // button, surface the error inline (in addition to the snackbar
    // the controller already shows), and let the provider try again.
    setState(() {
      _submitting = false;
      _errorText =
          'Incorrect code. Please check with the customer and try again.'.tr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work started'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Ask the customer for their 6-digit confirmation code to complete the job.'.tr,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          enabled: !_submitting,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(),
            hintText: 'Enter OTP'.tr,
            errorText: _errorText,
            errorMaxLines: 2,
            enabledBorder: _errorText != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  )
                : null,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6DA54B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _submitting
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Complete Work'.tr),
          ),
        ),
      ],
    );
  }
}
