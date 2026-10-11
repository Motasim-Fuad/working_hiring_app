import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

void showSetHoursDialog(
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
                    Get.snackbar(
                      "Error".tr,
                      "Please enter a valid number of hours.".tr,
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
