import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/contextual_warning_banner.dart';

class TaskDetailSheet extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onPressedBtn;

  TaskDetailSheet({
    super.key,
    required this.job,
    required this.onPressedBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Use 90% of screen height
      height: Get.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24), // Spacer for perfect centering
                Text(
                  AppStrings.viewTask.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          ContextualWarningBanner(
            message:
                "Please review the job details carefully before sending a request.",
            backgroundColor: Color(0xFFE5F0FF), // Light Blue
            textColor: Color(0xFF004085), // Dark Blue Text
            iconColor: Color(0xFF007AFF), // Blue Icon
            icon: Icons.info_outline,
          ),

          // --- Scrollable Content ---
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),

                  // Job Title
                  Text(
                    job['title']?.toString() ?? 'Assemble an IKEA Desk',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Category
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        job['category']?.toString() ?? 'Home assistance',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFFFF3366), // Reddish pin from design
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        job['location']?.toString() ??
                            'San Francisco CA', // Fixed typo
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Date & Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF6A9B5D), // Green primary
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        job['date']?.toString() ?? '12 Jan, 2026',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        color: Color(0xFF6A9B5D),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        job['time']?.toString() ?? '10:00 AM',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Price (Safely casted to string and added $ if missing)
                  Text(
                    job['price'] != null
                        ? (job['price'].toString().contains('\$')
                              ? job['price'].toString()
                              : "\$${job['price']}")
                        : '\$80-\$100',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Details Heading
                  Text(
                    'Details'.tr, // Kept matching exact design typo
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Details Body
                  Text(
                    job['description']?.toString() ??
                        "I recently purchased an IKEA MICKE desk and need professional assistance with assembly. The desk is brand new and still in its original packaging. All parts, screws, and the instruction manual are included in the box.\n\nThe desk will be placed in my home office, which has enough space to work comfortably. I’m looking for someone with prior experience assembling IKEA furniture to ensure the desk is assembled correctly and securely.\n\nPlease bring your own basic tools, such as a screwdriver or power drill, to complete the assembly. All furniture parts will be ready on-site before you arrive. Free visitor parking and elevator access are available if needed.\n\nPlease bring your own basic tools (screwdriver or power drill). I’m available today after 5:00 PM, but the time is flexible if needed.",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- Bottom Fixed Button ---
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressedBtn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                    0xFF6A9B5D,
                  ), // Match the exact green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  "Offer Help".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
