import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/category_model.dart';
import 'helper_profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/sign_up/views/map_picker_view.dart';
import 'dart:io';
import '../../../core/widgets/responsive_layout.dart';
class CreateHelperProfileView extends GetView<HelperProfileController> {
  CreateHelperProfileView({Key? key}) : super(key: key);

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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fill in the details below to start offering your services.'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 32),

                  // ---------- LOGO PICKER ----------
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
                              backgroundImage: file != null ? FileImage(file) : null,
                              child: file == null
                                  ? Icon(Icons.person, size: 48, color: Colors.grey.shade500)
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
                                child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
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
                  // ---------------------------------

                  _buildTextField(
                    controller: controller.companyNameController,
                    label: 'Company / Individual Name',
                    hint: 'Enter your name or company',
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: controller.hourlyRateController,
                          label: 'Hourly Rate',
                          hint: 'e.g. 25.00',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: controller.minBookingHoursController,
                          label: 'Min. Hours',
                          hint: 'e.g. 2',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // ---------- CATEGORY DROPDOWN ----------
                  const _CategoryDropdown(),
                  // -------------------------------------

                  SizedBox(height: 24),
                  Text(
                    'Office Location'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Required to appear in search results'.tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 16),

                  // ---------- Address Line (read-only) ----------
                  _buildReadOnlyTextField(
                    controller: controller.addressLineController,
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
                  // ----- City, Lat, Lng fields are HIDDEN (only in controller) -----

                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () => controller.createProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create Profile'.tr,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  // Regular editable text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint.tr,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Read-only text field (for address)
  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: false, // ← makes it read-only
          decoration: InputDecoration(
            hintText: hint.tr,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50, // subtle background to indicate read-only
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  Private Dropdown Widget (same as before, no changes)
// ============================================================
class _CategoryDropdown extends StatefulWidget {
  const _CategoryDropdown({Key? key}) : super(key: key);

  @override
  State<_CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<_CategoryDropdown> {
  bool _isExpanded = false;
  HelperProfileController get c => Get.find<HelperProfileController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Categories'.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExpanded ? Color(0xFF4CAF50) : Colors.grey.shade300,
                width: _isExpanded ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final selected = c.selectedCategoryIds;
                    if (selected.isEmpty) {
                      return Text(
                        'Select categories'.tr,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      );
                    }
                    return Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: selected.map((id) {
                        final cat = c.availableCategories.firstWhere(
                              (cat) => cat.id == id,
                          orElse: () =>
                              CategoryModel(id: id, title: 'Unknown'.tr),
                        );
                        return Chip(
                          label: Text(cat.title ?? ''),
                          backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
                          labelStyle: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          deleteIcon: Icon(Icons.close, size: 14, color: Color(0xFF4CAF50)),
                          onDeleted: () => c.toggleCategory(id),
                        );
                      }).toList(),
                    );
                  }),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Obx(() {
                final categories = c.availableCategories;
                final selectedIds = c.selectedCategoryIds;
                if (categories.isEmpty && c.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (categories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No categories available'.tr)),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView(
                    shrinkWrap: true,
                    children: categories.map((cat) {
                      final isSelected = selectedIds.contains(cat.id);
                      return CheckboxListTile(
                        title: Text(cat.title ?? ''),
                        value: isSelected,
                        onChanged: (_) => c.toggleCategory(cat.id),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
