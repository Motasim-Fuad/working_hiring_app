import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:working_hiring/app/features/auth/sign_up/views/map_picker/map_picker_view.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/helper_profile/widgets/category_dropdown.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/create_helper_profile/widgets/create_helper_profile_text_field.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/create_helper_profile/widgets/create_helper_profile_read_only_text_field.dart';

class CreateHelperProfileView extends GetView<HelperProfileController> {
  const CreateHelperProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'.tr, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Up Your Profile'.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in the details below to start offering your services.'
                          .tr,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 32),

                    Center(
                      child: GestureDetector(
                        onTap: controller.pickLogo,
                        child: Obx(() {
                          final file = controller.logoFile.value;
                          return Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: file != null
                                    ? FileImage(file)
                                    : null,
                                child: file == null
                                    ? Icon(
                                        Icons.person,
                                        size: 48,
                                        color: Colors.grey.shade500,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap to add a logo / photo'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 24),

                    CreateHelperProfileTextField(
                      fieldController: controller.companyNameController,
                      label: 'Company / Individual Name',
                      hint: 'Enter your name or company',
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CreateHelperProfileTextField(
                            fieldController: controller.hourlyRateController,
                            label: 'Hourly Rate',
                            hint: 'e.g. 25.00',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CreateHelperProfileTextField(
                            fieldController:
                                controller.minBookingHoursController,
                            label: 'Min. Hours',
                            hint: 'e.g. 2',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    const CategoryDropdown(),

                    SizedBox(height: 24),
                    Text(
                      'Office Location'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Required to appear in search results'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 16),

                    CreateHelperProfileReadOnlyTextField(
                      fieldController: controller.addressLineController,
                      label: 'Address Line',
                      hint: 'Address will be auto-filled from current location',
                    ),
                    SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Get.to(() => MapPickerView());
                          if (result != null && result is LatLng) {
                            await controller.setLocationFromMap(
                              result.latitude,
                              result.longitude,
                            );
                          }
                        },
                        icon: Icon(Icons.map, size: 18),
                        label: Text("Pick on Map".tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF4CAF50),
                          side: BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.createProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Profile'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              ),
          ],
        );
      }),
    );
  }
}
