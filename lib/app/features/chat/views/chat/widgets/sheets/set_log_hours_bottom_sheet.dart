import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

void showSetLogHoursBottomSheet(
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
                initialValue: selectedHours.value,
                hint: Text(
                  "Select hours".tr,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text("Hours Count".trParams({'count': v})),
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
                      Get.snackbar(
                        "Error".tr,
                        "Please select the hours worked.".tr,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
