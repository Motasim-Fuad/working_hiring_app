import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class LocationListBottomSheet extends GetView<HomeController> {
  LocationListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Location'.tr,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 16.h),
          _buildAddressList(),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.openAddNewAddressMap(),
              icon: Icon(Icons.add),
              label: Text('Add New Address'.tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6CA34D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return Obx(() {
      if (controller.userAddresses.isEmpty) {
        return Padding(
           padding: EdgeInsets.symmetric(vertical: 20.h),
           child: Text("No saved addresses.".tr, style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.userAddresses.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, index) {
          final address = controller.userAddresses[index];
          final addressText = address.addressLine ?? address.city ?? '';
          final isSelected = addressText == controller.currentAddress.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.location_on,
              color: isSelected ? Color(0xFF6CA34D) : Colors.grey.shade400
            ),
            title: Text(
              addressText,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black87
              )
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) Icon(Icons.check_circle, color: Color(0xFF6CA34D)),
                if (isSelected) SizedBox(width: 8.w),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 22.sp),
                  onPressed: () => controller.deleteAddress(index),
                ),
              ],
            ),
            onTap: () => controller.selectAddress(address),
          );
        },
      );
    });
  }
}
