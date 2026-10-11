part of 'edit_helper_profile_view.dart';

class _EditHelperProfileViewState extends State<EditHelperProfileView> {
  final HelperProfileController controller =
      Get.find<HelperProfileController>();

  @override
  void initState() {
    super.initState();
    controller.populateEditFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'.tr, style: TextStyle(color: Colors.black)),
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
                      'Update Information'.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Modify your profile details below.'.tr,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 32),

                    Center(
                      child: GestureDetector(
                        onTap: controller.pickLogo,
                        child: Obx(() {
                          final file = controller.logoFile.value;
                          final logoUrl = controller.profileData.value?.logo;

                          ImageProvider? imageProvider;

                          if (file != null) {
                            imageProvider = FileImage(file);
                          } else if (logoUrl != null && logoUrl.isNotEmpty) {
                            imageProvider = NetworkImage(logoUrl);
                          }

                          return Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: imageProvider,
                                child: imageProvider == null
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

                    EditHelperProfileTextField(
                      fieldController: controller.companyNameController,
                      label: 'Company / Individual Name',
                      hint: 'Enter your name or company',
                    ),
                    SizedBox(height: 20),

                    EditHelperProfileTextField(
                      fieldController: controller.detailsController,
                      label: 'Profile Details / Description',
                      hint: 'Write a brief description about your services',
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: EditHelperProfileTextField(
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
                          child: EditHelperProfileTextField(
                            fieldController:
                                controller.minBookingHoursController,
                            label: 'Min. Hours',
                            hint: 'e.g. 2',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    const CategoryDropdown(),

                    Text(
                      'Office Location'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pick your location on the map'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    SizedBox(height: 16),

                    EditHelperProfileReadOnlyTextField(
                      fieldController: controller.addressLineController,
                      label: 'Address Line',
                      hint: 'Pick on map to fill address',
                    ),
                    SizedBox(height: 16),

                    EditHelperProfileReadOnlyTextField(
                      fieldController: controller.cityController,
                      label: 'City',
                      hint: 'Pick on map to fill city',
                    ),
                    SizedBox(height: 24),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Availability Status'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: controller.isAvailable.value,
                            onChanged: (val) =>
                                controller.isAvailable.value = val,
                            activeThumbColor: Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.updateProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes'.tr,
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
              Container(
                color: Colors.white.withValues(alpha: 0.5),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                ),
              ),
          ],
        );
      }),
    );
  }
}
